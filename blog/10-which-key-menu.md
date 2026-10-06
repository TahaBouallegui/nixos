# A popup menu that's just a list

Every desktop needs a few actions that don't deserve a permanent keybind
but still need to be one keypress away — toggle Bluetooth, open the volume
mixer, launch the browser. The usual answer is a bar applet, or a
dedicated keybind for each one, or a launcher menu you maintain by hand in
some other tool's config format. Mine is a single Nix function:

```nix
flake.mkWhichKeyExe = pkgs: menu: lib.getExe (mkWhichKey pkgs menu);
```

Call it with a plain list of actions, and it hands back a ready-to-run
executable — fully themed, fully wired, no separate config file to author:

```nix
"Mod+G".spawn-sh = self.mkWhichKeyExe config.pkgs [
  { key = "b"; desc = "Bluetooth"; cmd = "${noctaliaExe} ipc call bluetooth togglePanel"; }
  { key = "w"; desc = "Wifi";      cmd = "${noctaliaExe} ipc call wifi togglePanel"; }
  { key = "l"; desc = "Librewolf"; cmd = "librewolf"; }
  { key = "d"; desc = "Discord";   cmd = "vesktop"; }
];
```

Press `Mod+G` in niri, get a popup listing every entry with its key and
description, press the letter, done. The entire feature — the menu's
existence, its contents, its keybind — is that one list. Add an entry, it
shows up. Remove one, it's gone. There's no menu-definition language to
learn beyond "here's a list of three fields."

## What's actually happening underneath

`mkWhichKeyExe` isn't a UI toolkit, it's a thin, honest wrapper around
[`wlr-which-key`](https://github.com/wlrfx/wlr-which-key), a real standalone
binary that reads a YAML config and draws the popup. The function's whole
job is turning a Nix list into that YAML, with the rest of the desktop's
theme already applied:

```nix
mkWhichKey = pkgs: menu: (self.wrappersModules.which-key.apply {
  inherit pkgs;
  settings = {
    inherit menu;
    font = "JetBrainsMono Nerd Font 12";
    background = self.theme.base00;
    color = self.theme.base06;
    border = self.theme.base0F;
    anchor = "bottom-right";
  };
}).wrapper;
```

No new dependency to theme by hand, no second place color values have to
agree with the rest of the system — `self.theme.base00` is the exact same
value every other themed app in the config already uses. The function
doesn't know or care what's *in* the menu; it only knows how to turn
"a list of actions" into "a themed executable," which means the exact same
function works for a desktop-wide launcher *or* a tiny two-item menu
somewhere else entirely, with zero new code either way.

## Why a function beats a config file here

The appeal isn't the popup itself — `wlr-which-key` alone gets you that.
It's that the menu is defined as *data*, in the same language as
everything else wiring the system together, instead of as a separate YAML
file living outside the Nix config that nothing checks for consistency.
Rename a command, change a description, add a submenu-worthy pile of new
shortcuts — it's all just editing a Nix list, type-checked and evaluated
the same way as every other option in the repo, not a config format that
only this one tool understands.
