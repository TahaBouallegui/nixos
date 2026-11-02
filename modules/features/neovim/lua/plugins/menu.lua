return {
    "menu",
    keys = {
        {
            "<leader>m",
            function() require("menu").open("main", { border = true }) end,
            desc = "menu",
        },
    },
}
