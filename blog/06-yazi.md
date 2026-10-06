# A file manager that lives in the terminal, and looks like it belongs there

Graphical file managers are fine. They're also a context switch — a
different window, a different set of keybinds, a mouse if you're not
careful. [`yazi`](https://yazi-rs.github.io/) stays in the terminal,
answers to the same vim-flavored muscle memory as everything else, and
turns out to be extensible enough to replace most of what a GUI file
manager does anyway.

## Plugins that earn their keep

Every plugin here is bound to something specific, not just installed and
left idle:

- **`git`** shows modified/staged/untracked status inline next to files
  and directories, the same information `git status` gives you, visible
  without leaving the file tree.
- **`smart-enter`** collapses "enter this directory" and "open this file"
  into one key — no mental branch required at the moment you press it.
- **`zoom`** and **`drag`** make images and drag-out-to-another-app
  interactions work without reaching for a mouse.
- **`gvfs`** mounts network locations on demand, from inside the file
  manager, the same place you're already browsing from.

None of these are default yazi behavior — they're plugins, configured
declaratively, with their keymaps and (for the ones that need it, like
`gvfs`) their Lua `init.lua` setup calls generated straight from Nix.

## Theming that isn't an afterthought

The same gruvbox palette that drives the terminal and the editor drives
yazi too — every section of its theme (the status bar, the selection
highlight, file-type colors, the which-key-style hint popup) mapped by
hand to the same base16 values used everywhere else in the config. Open
yazi, a terminal, or the editor, and nothing about the color story changes
— there's no "this app's theme" versus "that app's theme," just one
consistent palette expressed consistently.

## The git-status plugin isn't a toy

Having modified-file indicators inline in the file tree sounds like a
small convenience until it's gone — browsing a repo without it feels like
`ls` with the colors turned off. It's the kind of detail that only matters
because everything *around* it is also fast: no GUI chrome to wait on, no
window to switch focus to, just a file tree that already knows what you
changed, right where you're already looking.
