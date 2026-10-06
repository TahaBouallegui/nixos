# One flake, three machines that barely resemble each other

A ThinkPad laptop. A desktop tower with a different GPU vendor entirely. A
headless server with no display at all, sitting somewhere it's never
touched directly. Three machines that share almost nothing in terms of
hardware, all built from the same flake, all evaluated from the same
`nix eval` command with nothing but a hostname swapped.

## What's actually shared

Nearly everything that *isn't* hardware. The desktop environment, the
editor, the terminal, the shell, the secrets plumbing, the Nix settings —
all of it lives in `modules/features/` and `modules/base/`, written once,
imported by whichever hosts want it:

```nix
# Amal/configuration.nix (laptop)
imports = [ self.nixosModules.desktop self.nixosModules.gaming ... ];

# myMachine/configuration.nix (desktop tower)
imports = [ self.nixosModules.desktop ... ];
```

Both get the exact same niri setup, the exact same Neovim config, the
exact same terminal — not copies that happened to start identical and will
inevitably drift, but the literal same module, evaluated twice. Fix a bug
in the desktop config once, both machines get the fix on their next
rebuild. There's no second copy to remember to update.

## What's deliberately not shared

Hardware, obviously — each host's `hardware.nix` is the untouched output
of `nixos-generate-config`, specific to that exact machine's disks and
boot setup, and explicitly documented as off-limits to hand-edit. But also
anything that's a genuine *fact* about one specific box rather than a
preference: how many CPU cores to use for parallel builds, which
hostname a shared module should treat as "this machine" when asking the
language server for completions, where the flake happens to be checked
out on disk.

Those host-specific facts flow in through small, explicit environment
variables set once per host (`$NIXD_HOST`, `$NH_FLAKE`) rather than
getting hardcoded into the shared modules themselves — the shared code
stays genuinely shared, and the one or two facts that can't be shared stay
contained to exactly the one file that knows them.

## The discipline that keeps it from drifting

The rule that makes this actually hold up over time: a feature module
never knows which hosts import it, and a host config never edits another
host's file to get something done. Adding a capability to the laptop means
writing one file and importing it in one place — never touching the
server's config, never risking a change meant for one machine leaking into
another by accident. Three very different machines, and the only places
they're allowed to actually *differ* are the places where reality insists
on it.
