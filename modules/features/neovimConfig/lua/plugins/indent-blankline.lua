local colorscheme = require("colorscheme")
return {
    "indent-blankline.nvim",
    lazy = false,
    after = function()
        require("ibl").setup({
            -- no full-file dotted guides; scope feature only:
            -- 3.10.1 has no indent.enabled key, blank char hides the guides
            indent = { char = "" },
            scope = {
                enabled = true,
                char = "",
                show_start = false,
                show_end = false,
            },
        })
        -- make the scope bar stand out like the reference image
        vim.api.nvim_set_hl(0, "IblScope", { fg = colorscheme.teal, default = true })
    end,
}
