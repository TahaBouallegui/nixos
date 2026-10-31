-- nvzone/menu entries, opened by <leader>m (see lua/plugins/menu.lua).
-- `rtxt` is both the label drawn at the right edge and a buffer-local mapping
-- inside the menu window, so it doubles as the accelerator -- the values that
-- mirror an existing keymap are the real ones. `items` is either a nested
-- table or a string naming another menu module: "lsp" and "gitsigns" are the
-- submenus nvzone/menu ships itself.
return {
    { name = " Find Files",   cmd = function() require("snacks").picker.smart() end,   rtxt = "<leader>ff" },
    { name = " Find Text",    cmd = function() require("snacks").picker.grep() end,    rtxt = "<leader>fg" },
    { name = " Recent Files", cmd = function() require("snacks").picker.recent() end,  rtxt = "<leader>fo" },

    { name = "separator" },

    {
        name = " File Explorer",
        cmd = function() require("mini.files").open(vim.api.nvim_buf_get_name(0), false) end,
        rtxt = "<leader>e",
    },
    { name = " Delete Buffer", cmd = function() require("snacks").bufdelete() end,     rtxt = "d" },

    { name = "separator" },

    { name = " Format Buffer", cmd = vim.lsp.buf.format,                              rtxt = "<leader>F" },
    {
        name = " Code Actions",
        cmd = function() require("fastaction").code_action() end,
        rtxt = "<leader>a",
    },

    { name = "separator" },

    { name = "  LSP", hl = "ExBlue", items = "lsp",      keybind = "l" },
    { name = "  Git", hl = "ExBlue", items = "gitsigns", keybind = "g" },

    { name = "separator" },

    { name = " LazyGit", cmd = function() require("snacks").lazygit() end,            rtxt = "<leader>gg" },
}
