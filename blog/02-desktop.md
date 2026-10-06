# A desktop that scrolls instead of stacking

Most desktop environments want you to manage windows: resize them, tile
them, alt-tab through a stack of them. [niri](https://github.com/YaLTeR/niri)
doesn't really have a stack. Windows live in columns on an infinitely
scrolling strip, and the whole interaction model is "move along the strip,"
not "arrange things in a grid." Once it clicks, going back to a stacking
window manager feels like working with one hand tied behind your back.

## The desktop is one package

Everything — niri itself, the bar, the launcher, the colors — is wired
together through [`nix-wrapper-modules`](https://github.com/BirdeeHub/nix-wrapper-modules)
into a single derivation:

```nix
packages.desktop = inputs.wrapper-modules.wrappers.niri.wrap {
  inherit pkgs;
  imports = [ self.wrappersModules.niri ];
  terminal = lib.getExe self'.packages.terminal;
  env.EDITOR = lib.getExe self'.packages.neovim;
};
```

That means "my desktop" isn't a loose pile of dotfiles that happen to sit
next to each other — it's one buildable, reproducible thing. The whole
environment — compositor config, panel, launcher, theme — either builds
correctly together or it doesn't build at all. There's no state where half
of it updated and the other half didn't.

[noctalia-shell](https://github.com/noctalia-dev/noctalia-shell) runs
alongside it as the bar/launcher/control-center layer, themed to match a
gruvbox palette that's shared across every app in the stack — terminal,
editor, file manager, bar — from one set of color definitions in the Nix
config, not copy-pasted into five different config formats by hand.

## Discoverability over memorization

The thing about a heavily keybind-driven workflow is that it only stays
usable if you can actually remember the keybinds, and I couldn't. The fix
wasn't to memorize harder — it was `which-key.nvim`-style: press the leader
key, pause, and a menu shows you every available continuation with its
description, pulled directly from the same `desc` strings the real
keybinds are already declared with. No separate cheat sheet to keep in
sync, because there's nothing to keep in sync — the menu *is* the
keybinds.

The niri side gets the same treatment through a hand-rolled which-key
launcher (`self.mkWhichKeyExe`) bound to `Mod+G`: Bluetooth, Wi-Fi, a
browser, Discord, a volume mixer, one keypress away, discoverable instead
of memorized. The philosophy threads through the whole desktop: build
things that are *fast once you know them*, but don't make knowing them a
prerequisite for using them at all.
