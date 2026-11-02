return {
    "which-key.nvim",
    event = "DeferredUIEnter",
    after = function()
        local wk = require("which-key")
        wk.setup({})
        wk.add({
            { "<leader>f", group = "find" },
        })
    end,
}
