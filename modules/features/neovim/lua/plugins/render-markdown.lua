return {
    "render-markdown.nvim",
    ft = { "markdown" },
    after = function()
        require("render-markdown").setup({
            -- markdown only: the treesitter markdown/markdown_inline parsers
            -- were added to neovim.nix for this plugin, don't let the plugin
            -- try to render filetypes we have no parsers for (its defaults
            -- also include typst).
            file_types = { "markdown" },
        })
    end,
}
