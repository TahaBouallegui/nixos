# An editor built up from nothing, on purpose

It would have been faster to pick a Neovim distribution and move on.
LazyVim, NvChad, any of the big ones would have gotten syntax highlighting
and LSP support working in an afternoon. Instead, this config has none of
them — plugins, colorscheme, keymaps, LSP wiring, all written from an
empty `init.lua` up. Slower to start. Impossible to end up with a config
you don't understand every line of.

## Lazy by default, not by accident

Every plugin declares its own load trigger through
[`lz.n`](https://github.com/nvim-neorocks/lz.n) — on a keypress, on a
filetype, on a command, or genuinely eagerly if it needs to be:

```lua
return {
  "nvim-treesitter",
  event = "DeferredUIEnter",
}

return {
  "fastaction.nvim",
  keys = { { "<leader>a", function() require("fastaction").code_action() end } },
}
```

Nothing pays its startup cost until something actually asks for it. The
plugin list reads less like a shopping list and more like a dependency
graph with explicit edges — this loads when that key is pressed, that
loads when this filetype opens.

## A colorscheme and a grammar, both mine

The colorscheme (`gxvjbox`) isn't a port of something — it's a from-scratch
gruvbox-derived palette, defined once as a set of hex values and applied
consistently to every highlight group by hand, then reused *outside*
Neovim entirely: the same base16 table drives the terminal, the file
manager, the bar. One palette, one source of truth, every tool in the
stack agreeing with every other tool about what color "red" is.

The more unusual piece: a couple of personal file formats of mine — small
custom syntaxes I use for my own project files — get real tree-sitter
support, because I wrote the grammar myself. A compiled C parser, proper
syntax queries, even a [topiary](https://topiary.tweag.io/) formatting
query, all living in `neovimConfig/` right next to the rest of the editor
config. It's the kind of thing a prebuilt Neovim distro structurally can't
give you — support for a format nobody else has ever heard of, because
nobody else needed it, because it's mine.

## Flake-aware, not just Nix-aware

The Nix language server doesn't just know Nix syntax here — it's pointed
directly at this flake's own evaluated option set, so autocomplete on a
NixOS option isn't generic nixpkgs documentation, it's *this repository's*
actual, current, custom module tree:

```lua
options.nixos.expr = '(builtins.getFlake (toString ./.)).nixosConfigurations.amal.options'
```

Writing the config that configures the editor, inside an editor that
understands the config it's configuring, turns out to be a genuinely nice
place to work from.
