# nixos

Mypersonal NixOS configuration — a single flake covering three machines,
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
  `secrets` (sops-nix wiring).
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

## Hosts

| Host | Hostname | Role |
|---|---|---|
| `amal` | `amal` | ThinkPad T480 laptop — niri/Wayland desktop, hybrid Intel/NVIDIA graphics, gaming, local LLM serving |
| `myMachine` | `nixos` | Desktop tower — niri/Wayland desktop, NVIDIA |
| `robotechServer` | `lingangu` | Headless server — Immich, SearXNG, Grocy, remote desktop, Tailscale |

## Notable bits

- **Desktop**: [niri](https://github.com/YaLTeR/niri) (scrolling-tile Wayland
  compositor) + [noctalia-shell](https://github.com/noctalia-dev/noctalia-shell),
  kitty, a from-scratch Neovim config (own colorscheme, LSP setup, and even a
  custom tree-sitter grammar under `neovimConfig/vjxl-ts/`).
- **Secrets**: [sops-nix](https://github.com/Mic92/sops-nix), age-encrypted,
  keyed off existing SSH host/user keys (`ssh-to-age`) rather than separate
  age keypairs — nothing plaintext ever touches the repo or the Nix store.
- **Self-hosted services** (`robotechServer`): Immich (photos), SearXNG
  (meta-search), Grocy (household inventory), plus a Minecraft server managed
  with `mcman`.
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
