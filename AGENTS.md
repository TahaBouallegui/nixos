# AGENTS.md — guidance for AI agents working on this repo

Personal NixOS monorepo (atb). Flake-parts + `vic/import-tree`. Three hosts:
`amal` (ThinkPad T480 laptop — the machine you are usually running ON),
`myMachine` (hostname `nixos`), `robotechServer` (hostname `lingangu`).

## Layout & philosophy (follow it, don't fight it)

- `outputs` = `flake-parts mkFlake (import-tree ./modules)` — **every `*.nix`
  file under `modules/` is auto-imported as a flake-parts module** (paths
  containing `/_` are skipped). Nothing is registered manually.
- Every module file exports one option: `flake.nixosModules.<name> = { config, pkgs, ... }: { ... }`.
- Layering:
  - `modules/base/` — shared plumbing (`base`, `pkgs-stable`, `secrets`).
  - `modules/features/` — host-agnostic, drop-in capabilities (tailscale, nvidia,
    searxng, ...). A feature may carry data files/dirs next to its `.nix`.
  - `modules/hosts/<Name>/` — `default.nix` defines `flake.nixosConfigurations.<host>`,
    `configuration.nix` defines the config module and composes features via
    `imports = [ self.nixosModules.<feature> ]`, `hardware.nix` is the nixos-generate-config output.
- Adding a capability: write `modules/features/<name>.nix`, import it in the
  host's `configuration.nix`. Never touch another host's config to do it.
- Cross-module data flows through `flake.*` outputs (`self.theme`,
  `self.wrappersModules`, `self.mkWhichKeyExe`, `self.packages`, ...).
- Code style: nixfmt (two-space indent, trailing commas, `=` aligned sets).
  `modules/hosts/robotechServer/configuration.nix` predates this convention and
  is still in the old compact/no-trailing-comma style — don't let it set the
  precedent for new files.
- No AI-slop: no comment noise, no dead code, no unrelated refactors.

## ⚠️ The gotcha that will bite you

Nix (2.34, `git+file://` flake source) **only sees files that are in the git
index**. A brand-new untracked `.nix` file is invisible to eval — the symptom
is a misleading `attribute '<module>' missing` on `self.nixosModules`. Fix
before evaluating anything new:

```sh
git add -N <the-new-files>   # intent-to-add, no staging of contents
```

Never `git commit` unless atb explicitly asks.

## Secrets: sops-nix

- `secrets/secrets.yaml` (repo root) holds all secrets, sops-encrypted.
  `.sops.yaml` lists age recipients: atb's personal key (derived from
  `~/.ssh/id_ed25519`, `age1u2wj...`) and amal's **host** key (derived from
  `/etc/ssh/ssh_host_ed25519_key`, `age18gr7...`) — both via `ssh-to-age`, no
  separate age keypairs.
- `modules/base/secrets.nix` (`self.nixosModules.secrets`) wires `sops-nix` and
  `sops.defaultSopsFile`; currently imported by `amal` only. Feature modules
  that need a secret `import` this module — they never touch the sops plumbing
  themselves.
- Secrets land at `/run/secrets/<name>` at activation (host decrypts via
  `sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ]`). Config files
  that embed a secret are rendered with `sops.templates.<name>.content` using
  `${config.sops.placeholder.<name>}` and can be pointed at arbitrary runtime
  paths via the template's `path` option.
- **Hard rules**: never put plaintext credentials anywhere in this repo or the
  nix store; public material (CA certs) may live in the open. Never eval-time a
  secret into the store.
- Edit secrets: `sops secrets/secrets.yaml`. If sops finds no identity on a
  given machine: `mkdir -p ~/.config/sops/age && nix run nixpkgs#ssh-to-age -- -private-key -i ~/.ssh/id_ed25519 > ~/.config/sops/age/keys.txt`
- New host onboarding: `nix run nixpkgs#ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub`,
  append the result to `.sops.yaml` under `keys:` and that host's
  `creation_rules` group, then `sops updatekeys secrets/secrets.yaml`, then
  import `self.nixosModules.secrets` in that host's `configuration.nix`.
- Only `amal` can currently decrypt `secrets/secrets.yaml` — `myMachine` and
  `robotechServer` are not yet enrolled as recipients. Onboard them (above)
  before wiring any secret-dependent feature into those hosts.

## secretspec

- `modules/features/secretspec.nix` (`self.nixosModules.secretspec`, imported
  by `amal`) just puts the `secretspec` CLI (`pkgs.secretspec`, from
  nixpkgs-unstable) on `PATH`. It's a per-*project* tool, not NixOS plumbing:
  a project commits a `secretspec.toml` declaring which secrets it needs, and
  `secretspec run -- <cmd>` resolves them at runtime from whichever provider
  is configured (keyring, 1Password, `.env`, sops, ...) — nothing to wire up
  here beyond having the binary available.
- It can use `secrets/secrets.yaml` as a provider backend (`sops` provider,
  secretspec ≥0.17) if a project wants to share atb's existing sops secrets
  instead of its own store; not currently configured for any project in this
  repo.

## Verify like this (no builds needed)

```sh
cd /home/atb/.config/nixos
nix eval ".#nixosConfigurations.amal.config.networking.hostName"
nix eval ".#nixosConfigurations.amal.config.system.build.toplevel.drvPath"   # full closure eval
nix eval --raw '.#nixosConfigurations.amal.config.sops.templates."<name>".content'  # must show SOPS placeholder, never a password
nix run nixpkgs#sops -- --decrypt secrets/secrets.yaml >/dev/null             # sops roundtrip (needs a local identity, see above)
```

All three hosts must keep evaluating:
`myMachine`, `robotechServer` too (swap the host name above).
Deploy with `sudo nixos-rebuild switch --flake /home/atb/.config/nixos#<host>`.

## Known pre-existing warts

- `self.packages.${pkgs.system}.environment` in `modules/hosts/Amal/configuration.nix`
  and `modules/hosts/robotechServer/configuration.nix` (3 call sites) triggers
  the `pkgs.system` → `pkgs.stdenv.hostPlatform.system` deprecation warning.
  `llama.nix` already uses the correct form; the host configs don't yet.
  Harmless, but don't be surprised by the warning and don't "fix" it as an
  unrelated drive-by in an unrelated change.
- Flake inputs `home-manager` and `microvm` are declared but currently
  **unreferenced** by any module — `home-manager` looks aspirational,
  `microvm` is orphaned leftover from the removed microVM feature (see next
  point). Don't assume either is wired up; check before relying on it.
- The microVM-on-`robotechServer` feature (`modules/features/microvms.nix`,
  guests `vm1`/`vm2`) was removed. `robotechServer/configuration.nix` keeps a
  commented-out `#self.nixosModules.microvms` import as a breadcrumb. If it
  comes back, re-derive the module rather than trusting old memory of it —
  don't assume the previous guest-networking/state layout still applies.
