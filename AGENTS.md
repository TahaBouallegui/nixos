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
  - `modules/base/` — shared plumbing (`base`, `pkgs-stable`, `secrets`, `nix`
    — the last is nix settings/gc/allowUnfree every host wants; it deliberately
    excludes `max-jobs`/`cores`, which track each machine's real core count).
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
- **Host-specific values don't belong hardcoded in `modules/features/`** — a
  feature module importable by multiple hosts (e.g. `neovimConfig/neovim.nix`
  for `nixd`'s flake-aware option) reads a per-host env var instead
  (`$NIXD_HOST`, `$NH_FLAKE` — set in each host's `environment.sessionVariables`)
  rather than hardcoding a path or hostname that's only true on one machine.
- **Don't let a wrapped/configured package coexist with the bare nixpkgs one.**
  When a feature installs `self.packages.<name>` (a themed/configured wrapper)
  or `pkgs.<name>-with-db`-style variant, remove the plain `pkgs.<name>` from
  wherever it's also listed. Two providers of the same binary on `PATH` is a
  silent shadowing bug, not a redundancy — hit this twice (`yazi` vs
  `self.packages.yazi`, `comma` vs `comma-with-db`).

## ⚠️ The gotcha that will bite you

Nix (2.34, `git+file://` flake source) **only sees files that are in the git
index**. This isn't limited to `*.nix` modules — it applies to *any* file
pulled in through a path literal in a tracked `.nix` file, including whole
directories copied wholesale (e.g. `neovimConfig/`'s
`settings.config_directory = ./.`). A brand-new untracked file silently isn't
there: for a `.nix` module the symptom is a misleading `attribute '<module>'
missing` on `self.nixosModules`; for something like a new
`lua/plugins/*.lua` file the symptom is much sneakier — the build succeeds,
the file is just absent from the result, and whatever it configured silently
never loads. Fix before evaluating *or building* anything new:

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

## Firewall & tailscale

- `modules/features/tailscale.nix` sets `networking.firewall.trustedInterfaces
  = [ "tailscale0" ]` (tailnet traffic bypasses port filtering entirely) plus
  the nftables wiring. **That trust only exists if a host actually imports
  `self.nixosModules.tailscale`** — inlining a bare
  `services.tailscale.enable = true;` in a host's own `configuration.nix`
  gets you the VPN but *not* the firewall trust, and every self-hosted
  service on that host silently becomes unreachable even over the tailnet.
  `nix eval` won't catch this — it only shows up at runtime. Caught this on
  `robotechServer` after it had been live for a while; always import the
  shared module, never re-inline `services.tailscale.enable`.
- Ports currently in use, check before adding a new network service:
  `8900` searxng, `8901` llama-cpp (was `8900`, collided), `2283` immich
  (`openFirewall = true`), `3389` xrdp (`remote-desktop.nix`,
  `allowedTCPPorts`), `8096`/`8920` jellyfin + `1900`/`7359` UDP
  (`openFirewall = false` — tailnet-only, relies on `trustedInterfaces`
  above, not an open port).
- Default posture for a new self-hosted service: **tailnet-only**
  (`openFirewall = false` or no firewall rule at all, reachable only via
  `trustedInterfaces`) unless atb explicitly says it needs to be reachable
  off the tailnet. Don't default to `openFirewall = true` or a raw
  `allowedTCPPorts` entry.
- `grocy.nix`: `services.grocy.nginx.enableSSL` defaults to `true`, which
  unconditionally forces `enableACME + forceSSL` on its vhost — set to
  `false` here on purpose, since `hostName = "grocy.tld"` isn't a real,
  publicly-resolvable domain and ACME would fail on every activation. Don't
  "fix" this by giving it a real `hostName` without checking with atb first;
  it's deliberately HTTP-only, tailnet-reachable.

## Wrapper-modules config (yazi, niri, kitty, neovim)

These go through `inputs.wrapper-modules` (`flake.wrappersModules.<name>` +
`inputs.wrapper-modules.wrappers.<name>.wrap { imports = [ self.wrappersModules.<name> ]; }`,
see `niri.nix`/`yazi.nix`) or `inputs.wrappers` (`.wrapperModules.<name>.apply`,
see `kitty.nix`). Don't guess these schemas from memory or docs prose —
verify against the real package before writing config:

- **yazi has no generic base16-style palette.** A flavor's `flavor.toml` needs
  every section's actual named fields (`mgr.cwd`, `status.perm_read`,
  `which.cand`, ...) — there's no `[theme] base00 = "..."` table you can
  reference elsewhere. Verify field names against a real shipped flavor
  (`pkgs.yaziPlugins.nord`'s `flavor.toml`), not the docs page.
- **A yazi flavor must be a directory** (`<name>.yazi/flavor.toml` once
  linked) — `pkgs.writeTextDir "flavor.toml" ''...''`, not
  `pkgs.writeTextFile`. The latter builds a flat file and yazi fails with
  "Not a directory" trying to read inside it.
- `yazi.toml`'s `plugin.prepend_fetchers` entries need `url` (not `name`) and
  `group`, both required, alongside `id`/`run`.
- **Verify a wrapped package for real**, not just `nix eval`: `nix build
  .#packages.x86_64-linux.<name>`, then actually run the built binary and
  grep its output for the *specific* known failure text (`"Failed to
  parse"`, `"missing field"`, etc.) — don't treat "didn't crash" as success.
  A sandbox has no real TTY, so e.g. yazi/zellij-style TUIs always print an
  `Inappropriate ioctl for device` line even when everything else is fine;
  filter that one out explicitly rather than treating any stderr output as
  failure.
- **Testing a Neovim config change headlessly**: `nvim --headless -c
  "luafile x.lua" -c "qa!"` runs *before* `VimEnter` ever fires (that's by
  vim's own design — `-c` commands run, then `VimEnter`, not the other way
  around) and `UIEnter` never fires at all with no attached UI, so anything
  gated on either (which-key's trigger setup, this config's `lua/plugins/`
  loading via `lz.n`) silently never initializes — `vim.v.vim_did_enter`
  stays `0` for the whole process. To test for real: load/register the
  plugin first (`require("lz.n").trigger_load("<name>")`), *then* fire
  `vim.api.nvim_exec_autocmds("VimEnter", { modeline = false })` — order
  matters, firing the event before the plugin registers its callback is a
  no-op.

## Vivado / FPGA tooling (opt-in, not wired into any host)

- `modules/features/vivado.nix` (`self.nixosModules.vivado`) is real,
  working infrastructure via the `xilinx-nix-utils` flake input — but
  **deliberately not imported anywhere**. The ~100GB installer needs a
  Xilinx/AMD account to download (can never be hermetic, on any distro) and
  needs ~100GB free disk (amal had 5GB free when this was written). Full
  setup/removal tutorial is in comments at the top of the file. Don't import
  it into a host without checking disk space and confirming atb actually
  wants the download step done first.

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
