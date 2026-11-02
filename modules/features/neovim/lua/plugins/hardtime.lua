return {
    "hardtime.nvim",
    event = "DeferredUIEnter",
    after = function()
        require("hardtime").setup({
            -- Off until asked for: <leader>m then H, or :Hardtime enable.
            enabled = false,
            -- opts.lua sets mouse = "a"; hardtime's default takes the mouse
            -- away in every buffer it doesn't consider special. Flip to true
            -- if you want that part of the drill.
            disable_mouse = false,
        })
    end,
}
