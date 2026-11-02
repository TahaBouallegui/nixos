local function config()
    local M = require("ls-shorthands")
    local ls = require("luasnip")

    ls.add_snippets("all", {
        M.s("__colorscheme_red", { M.t("#f38ba8"), }),
        M.s("__colorscheme_green", { M.t("#a6e3a1"), }),
        M.s("__colorscheme_magenta", { M.t("#f5c2e7"), }),
        M.s("__colorscheme_blue", { M.t("#89b4fa"), }),
        M.s("__colorscheme_darkblue", { M.t("#74c7ec"), }),
        M.s("__colorscheme_cyan", { M.t("#94e2d5"), }),
        M.s("__colorscheme_yellow", { M.t("#f9e2af"), }),
        M.s("__colorscheme_orange", { M.t("#fab387"), }),
        M.s("__colorscheme_fg", { M.t("#cdd6f4"), }),
        M.s("__colorscheme_fg_dark", { M.t("#bac2de"), }),
        M.s("__colorscheme_bg", { M.t("#1e1e2e"), }),
    })

    local function comment_string(_, _, _)
        local cs = string.gsub(vim.opt.commentstring["_value"], "%%s", "")
        cs = string.gsub(cs, " ", "")
        if cs == "/**/" then
            cs = "//"
        end
        return cs
    end

    local function smart_heading(args, _, user_args)
        local text_length = string.len(args[1][1])
        local newstring = ""

        if user_args.compensate == true then
            local is_even = text_length % 2
            if is_even == 1 then
                newstring = newstring .. user_args.symbol
            end
        end

        for _ = 0, ((user_args.count - text_length) / 2 - 3), 1 do
            newstring = newstring .. user_args.symbol
        end

        if user_args.compensate then
            return (' ' .. newstring .. user_args.outer)
        else
            return (user_args.outer .. newstring .. ' ')
        end
    end

    local function symbol_line(symbol, amount)
        local newstring = ""
        for _ = 0, amount, 1 do
            newstring = newstring .. symbol
        end
        return M.t(newstring)
    end

    local function comment_symbol_line(symbol, amount)
        return M.sn(2, {
            M.f(comment_string),
            M.t(" "),
            symbol_line('=', 63),
            M.t(" "),
            M.f(comment_string),

        })
    end

    local function smart_header_line(filled)
        local fillSymbol = ' '

        if filled then
            fillSymbol = "="
        end

        return M.sn(1, {
            M.f(comment_string),
            M.t(" "),
            M.f(smart_heading, { 1 },
                { user_args = { { compensate = false, symbol = fillSymbol, count = 64, outer = '=' } }, }),
            M.i(1),
            M.f(smart_heading, { 1 },
                { user_args = { { compensate = true, symbol = fillSymbol, count = 64, outer = '=' } } }),
            M.t(" "),
            M.f(comment_string),

        })
    end

    -- ================================================================ --
    -- =                           HEADER1                            = --
    -- ================================================================ --

    ls.add_snippets("all", {
        M.s("__HEADER1", {
            comment_symbol_line(),
            M.t({ "", "" }),
            smart_header_line(),
            M.t({ "", "" }),
            comment_symbol_line(),
            M.t({ "", "" }),
        })
    })

    ls.add_snippets("all", {
        M.s("__INNERHEADER", {
            smart_header_line()
        })
    })
    -- =========================== HEADER2 ============================ --

    ls.add_snippets("all", {
        M.s("__HEADER2", {
            smart_header_line(true)
        })
    })
end

return {
    "luasnip",
    lazy = false,
    after = config
}
