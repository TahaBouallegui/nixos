# One file, one capability: how I stopped maintaining an import list

Every NixOS config eventually grows the same ugly artifact: a giant list of
`imports = [ ./modules/this.nix ./modules/that.nix ... ]` somewhere near the
top, hand-maintained, always one step behind what's actually in the
directory. Add a file, forget to list it, and you get to enjoy debugging
"why isn't this doing anything" for twenty minutes before remembering the
import list exists.

Mine doesn't have one. The entire flake boils down to a single line:

```nix
outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
```

[`import-tree`](https://github.com/vic/import-tree) walks `modules/`
recursively and imports every `*.nix` file it finds as a
[flake-parts](https://flake.parts/) module. Drop a file in, it's live.
Delete it, it's gone. There's nothing to register, because there's nothing
*to* register — the filesystem *is* the import list.

## A convention, not a framework

Auto-discovery only stays sane if everything it discovers agrees on a
shape. Mine do: one file exports exactly one `flake.nixosModules.<name>`.

```nix
# modules/features/tailscale.nix
{ self, inputs, ... }:
{
  flake.nixosModules.tailscale = { config, ... }: {
    services.tailscale.enable = true;
    networking.firewall.trustedInterfaces = [ "tailscale0" ];
  };
}
```

A host doesn't know or care how `tailscale.nix` is organized internally —
it just asks for the capability by name:

```nix
imports = [
  self.nixosModules.tailscale
  self.nixosModules.nvidia
  self.nixosModules.desktop
];
```

That one convention is doing more work than it looks like. It means
"what does this machine have" is answerable by reading a dozen lines in one
file, not by reverse-engineering a sprawl of conditionals. It means adding
a capability to one machine never requires touching another machine's
config — there's no shared state to step on. And it means the repo scales
by *addition*, not by increasingly careful editing of something that
already exists.

## Three layers, three jobs

- **`base/`** — the plumbing every machine needs regardless of what it's
  for: Nix settings, garbage collection, secrets wiring. Not a feature you
  opt into, just the floor everything else stands on.
- **`features/`** — host-agnostic, drop-in capabilities. A search engine, a
  game launcher, a full text editor config, a Minecraft server. Each one
  assumes nothing about which machine imports it.
- **`hosts/<Name>/`** — one directory per physical machine, each composing
  whichever features that specific box actually needs, plus the
  hardware-specific bits (`hardware.nix`) that can never be shared because
  no two machines have the same disks.

Three machines — a laptop, a desktop tower, a headless server — share
almost the entire `features/` tree and diverge only where hardware or role
genuinely demands it. That's the whole point of the layering: shared by
default, divergent only on purpose, and never by accident.
