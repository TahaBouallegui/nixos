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
  - `modules/base/` — shared plumbing (`base`, `pkgs-stable`, `fixed-boot-date`, `secrets`).
  - `modules/features/` — host-agnostic, drop-in capabilities (tailscale, nvidia,
    eduroam, ...). A feature may carry data files/dirs next to its `.nix`.
  - `modules/hosts/<Name>/` — `default.nix` defines `flake.nixosConfigurations.<host>`,
    `configuration.nix` defines the config module and composes features via
    `imports = [ self.nixosModules.<feature> ]`, `hardware.nix` is the nixos-generate-config output.
- Adding a capability: write `modules/features/<name>.nix`, import it in the
  host's `configuration.nix`. Never touch another host's config to do it.
- Cross-module data flows through `flake.*` outputs (`self.theme`,
  `self.wrappersModules`, `self.mkWhichKeyExe`, `self.packages`, ...).
- Code style: nixfmt (two-space indent, trailing commas, `=` aligned sets).
  No AI-slop: no comment noise, no dead code, no unrelated refactors.

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
  `.sops.yaml` lists age recipients: amal's ssh **host** key (used by the
  machine at activation via `sops.age.sshKeyPaths`) and atb's
  `~/.ssh/id_ed25519` (used for editing from a shell).
- `modules/base/secrets.nix` (`self.nixosModules.secrets`) wires sops-nix and
  `defaultSopsFile`. Feature modules that need secrets `import` it — they never
  touch the sops plumbing themselves.
- Secrets land at `/run/secrets/<name>` at activation. Config files that
  embed a secret are rendered with `sops.templates.<name>.content` using
  `${config.sops.placeholder.<name>}` and can be pointed at arbitrary runtime
  paths via the template's `path` option.
- **Hard rules**: never put plaintext credentials anywhere in this repo or the
  nix store; public material (CA certs) may live in the open. Never eval-time a
  secret into the store.
- Edit secrets: `sops secrets/secrets.yaml`. If sops finds no identity:
  `mkdir -p ~/.config/sops/age && nix run nixpkgs#ssh-to-age -- -private-key -i ~/.ssh/id_ed25519 > ~/.config/sops/age/keys.txt`
- New host onboarding: append `nix run nixpkgs#ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub`
  to `.sops.yaml`, then `sops updatekeys secrets/secrets.yaml`.

## eduroam feature (added 2026-09-16, enabled on amal only)

- `modules/features/eduroam/` — `default.nix` + `ca.pem` (HARICA TLS RSA Root
  CA 2021 + GEANT TLS RSA 1, extracted from the univ-lille eduroam CAT
  installer; public material).
- Mechanism: sops template renders an `.nmconnection` (PEAP/MSCHAPv2, univ-lille
  identity, 4 RADIUS alt-subject pins, fixed uuid) to
  `/run/NetworkManager/system-connections/eduroam.nmconnection` (0600, root).
  NM's dir watcher picks it up at activation; autoconnect handles the rest.
  The password is sops key `eduroam-password`; it never touches the store.
- Do not manage this profile through nmcli/GUI on the machine — it is declarative.
- Reload machinery (non-obvious): sops-nix renders templates via the atomic
  `/run/secrets` symlink swap; the symlink inside the NM dir is not re-created
  on reactivation, so NM gets **no inotify event** and keeps its last (possibly
  failed) load. Trap catalog (each personally verified on this machine):
  1. `sops.templates.<x>.restartUnits/reloadUnits` — declared but **unwired
     no-ops** in the pinned sops-nix rev.
  2. `systemctl reload NetworkManager` (NM's `Reload()` with no flags) —
     re-reads config files only, **not** keyfile connections.
  3. Trigger properties (`X-Restart-Triggers`) on **never-started** units —
     ignored; systemd only re-acts on units that are active (or, for
     `restartIfChanged`, declaratively running).
  4. `PathModified` on the rendered path — watch dies at the generation swap
     (inode changes under the symlink).
  5. nixpkgs 26.x has **no `startIfChanged`** anymore (merged into
     `restartIfChanged`).
  Working pattern, keep it: `systemd.services.eduroam-nm-reload` is a oneshot
  with `remainAfterExit = true` + `wantedBy = [ multi-user.target ]` (so it is
  *active*, hence re-triggerable) whose `restartTriggers = [ <template>.file ]`
  runs `nmcli connection reload` — the only targeted keyfile re-read NM offers.
- Debugging: if the profile is missing from `nmcli connection show`, the render
  is fine but NM **rejected the file at parse time** — look in
  `journalctl -u NetworkManager` for `keyfile: load: ... eduroam ... failed`.
  NM's keyfile parsers are case-sensitive: enums like `phase2=auth=MSCHAPV2`
  must be uppercase (NM's own written form); `eap=peap;` is lowercase-canonical.
  The failure looks exactly like "no profile exists" (GUI credential prompt),
  so check the journal before suspecting sops. After any content fix, a
  reactivation must happen for NM to reload (see reload machinery above).

## Verify like this (no builds needed)

```sh
cd /home/atb/.config/nixos
nix eval ".#nixosConfigurations.amal.config.networking.hostName"
nix eval ".#nixosConfigurations.amal.config.system.build.toplevel.drvPath"   # full closure eval
nix eval --raw '.#nixosConfigurations.amal.config.sops.templates."eduroam.nmconnection".content'  # must show SOPS placeholder, never a password
nix shell nixpkgs#sops -c sops --decrypt secrets/secrets.yaml >/dev/null    # sops roundtrip
```

All three hosts must keep evaluating. Deploy with
`sudo nixos-rebuild switch --flake /home/atb/.config/nixos#amal`.

## Known pre-existing warts

- Deprecation warning `system -> stdenv.hostPlatform.system` comes from
  `pkgs.system` in `modules/features/llama.nix` (atb's WIP), unrelated to
  anything else; don't "fix" it as a drive-by.
