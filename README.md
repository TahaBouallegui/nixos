# nixos

My personal NixOS configuration — a single flake covering three machines,
built with [flake-parts](https://flake.parts/) and auto-discovery of modules
instead of hand-maintained import lists.

## How it's wired

```
outputs = flake-parts.lib.mkFlake { inherit inputs; } (import-tree ./modules);
```

Every `*.nix` file under `modules/` is auto-imported as a flake-parts module —
drop a file in, it's live, nothing to register by hand (via
[`vic/import-tree`](https://github.com/vic/import-tree)). Layout:

- **`modules/base/`** — shared plumbing: `base` (shared option surface),
  `pkgs-stable` (pins an `nixpkgs-stable` instance alongside unstable),
  `secrets` (sops-nix wiring), `nix` (experimental features, GC, unfree —
  every host wants this, so it's base rather than an opt-in feature).
- **`modules/features/`** — host-agnostic, drop-in capabilities. Each file
  exports exactly one `flake.nixosModules.<name>`: desktop environment,
  gaming, nvidia, tailscale, searxng, a Minecraft server, a full Neovim
  config, and so on. A feature may carry data files next to its `.nix`
  (wallpapers, server configs, Lua plugin specs).
- **`modules/hosts/<Name>/`** — one directory per machine. `default.nix`
  declares the `nixosConfiguration`, `configuration.nix` composes features
  via `imports = [ self.nixosModules.<feature> ... ]`, `hardware.nix` is the
  stock `nixos-generate-config` output.

Adding a capability to one machine means writing a feature file and importing
it in that host's `configuration.nix` — never editing another host's config.
Cross-cutting state (theme colors, a which-key launcher, wrapped packages)
flows through `flake.*` outputs (`self.theme`, `self.wrappersModules`,
`self.mkWhichKeyExe`, `self.packages`) rather than NixOS module-arg plumbing.
Host-specific values that a shared feature module needs (which machine's
`nixosConfigurations.<name>.options` to expose to `nixd`, where the flake
actually lives) are read from per-host env vars (`$NIXD_HOST`, `$NH_FLAKE`)
rather than hardcoded — keeps the feature modules themselves portable.

## Hosts

| Host | Hostname | Role |
|---|---|---|
| `amal` | `amal` | ThinkPad T480 laptop — niri/Wayland desktop, hybrid Intel/NVIDIA graphics, gaming, local LLM serving |
| `myMachine` | `nixos` | Desktop tower — niri/Wayland desktop, NVIDIA |
| `robotechServer` | `lingangu` | Headless server — Immich, Nextcloud, SearXNG, a Samba file share, remote desktop, Tailscale |

## Services (tailnet-only)

Everything below is reachable only from devices on the tailnet — no public
ports, see [Firewall & tailscale](./AGENTS.md#firewall--tailscale) in
`AGENTS.md` for how that's enforced. `lingangu.tail5481a4.ts.net` and
`100.68.187.8` are interchangeable (MagicDNS vs. raw tailscale IP).

| Service | Address |
|---|---|
| Immich (photos) | https://lingangu.tail5481a4.ts.net:2283 |
| Nextcloud (files) | https://lingangu.tail5481a4.ts.net:8099 |
| SearXNG (search) | https://lingangu.tail5481a4.ts.net:8900 |
| Samba share | `smb://lingangu.tail5481a4.ts.net/share` — declaratively mounted on `amal` at `/mnt/robotechserver` already; use this address to reach it from anywhere else |
| Remote desktop | RDP to `lingangu.tail5481a4.ts.net:3389` |

Every service above keeps the exact same port it always had — only the
scheme changed, `http://` → `https://`. Certs are real, browser-trusted ones
issued by Tailscale itself for `lingangu.tail5481a4.ts.net` (`tailscale
cert`, auto-renewed daily — see `modules/features/tailscale-certs.nix`), not
self-signed.

**Jellyfin and Grocy are currently not imported** (commented out in
`robotechServer/configuration.nix`) — both modules work, but each has a real
HTTPS wrinkle that isn't resolved yet: Jellyfin's NixOS module has no TLS
option at all, so enabling HTTPS there needs a one-time manual step in its
own dashboard rather than anything `nixos-rebuild` can do; Grocy's only port
is 80, and since `https://` doesn't default to port 80 the way `http://`
does, reaching it over HTTPS means typing the port explicitly
(`:80`) — worse than what it had before. See the comment at the top of each
file (`modules/features/jellyfin.nix`, `modules/features/grocy.nix`) for the
full explanation; re-import once either is resolved.

## Notable bits

- **Desktop**: [niri](https://github.com/YaLTeR/niri) (scrolling-tile Wayland
  compositor) + [noctalia-shell](https://github.com/noctalia-dev/noctalia-shell),
  kitty, a from-scratch Neovim config (own colorscheme, `which-key.nvim`,
  flake-aware `nixd` completion, and even a custom tree-sitter grammar under
  `neovimConfig/vjxl-ts/`).
- **Secrets**: [sops-nix](https://github.com/Mic92/sops-nix), age-encrypted,
  keyed off existing SSH host/user keys (`ssh-to-age`) rather than separate
  age keypairs — nothing plaintext ever touches the repo or the Nix store.
- **Self-hosted services** (`robotechServer`): Immich (photos), Nextcloud
  (files), SearXNG (meta-search), and a Samba share (`/srv/share`) mounted
  declaratively on `amal` at `/mnt/robotechserver`. Jellyfin and Grocy are
  written but not currently imported — see
  [Services](#services-tailnet-only) above for why. All of it is
  tailnet-only by default — no raw ports opened to the WAN, reachability
  comes from Tailscale's `trustedInterfaces`, not a firewall allow-list.
- **Instant shell lookups**: [`nix-index-database`](https://github.com/nix-community/nix-index-database)
  backs `,`/`comma` (`, cowsay hello` runs anything in nixpkgs ephemerally)
  and `nix-locate` with a weekly-updated prebuilt index — no local database
  build required.
- **Local LLM serving** (`amal`): `llama.cpp` (ik_llama.cpp fork, built with
  all-CPU-variant kernels) wired into a chat UI via
  [dsh](https://github.com/moraxyc/deepseek-harness.nix).

## Using this

```sh
# evaluate without building — fast sanity check
nix eval ".#nixosConfigurations.<host>.config.networking.hostName"

# deploy
sudo nixos-rebuild switch --flake .#<host>
```

`<host>` is one of `amal`, `myMachine`, `robotechServer`. Note: Nix only sees
files that are in the git index — a brand-new untracked `.nix` file is
invisible to eval until `git add -N` (or a real `git add`) picks it up.

This is a personal config, published as-is; hardware modules and host-specific
secrets obviously won't apply to your machine. See `AGENTS.md` for the deeper
conventions if you're poking around or adapting pieces of it.

## License

GPL-3.0 — see [`LICENSE`](./LICENSE).
