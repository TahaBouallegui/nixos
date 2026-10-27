-- Catppuccin Mocha highlight logic, following the official catppuccin/nvim
-- group mapping (lua/catppuccin/groups/{editor,syntax,terminal}.lua), with
-- styles flattened (their option machinery stripped) and blended backgrounds
-- precomputed as literals. Repo-specific additions: the kitty float-opacity
-- trick on NormalFloat, and the @vjv_embed capture for the custom videoscript
-- parser.
local C = require("colorscheme")

local highlights = {
    -- Editor
    ColorColumn = { bg = C.surface0 },
    Conceal = { fg = C.overlay1 },
    Cursor = { fg = C.base, bg = C.rosewater },
    CursorColumn = { bg = C.mantle },
    CursorIM = { fg = C.base, bg = C.rosewater },
    CursorLine = { bg = "#2a2b3c" }, -- darken(surface0, 0.64, base)
    CursorLineNr = { fg = C.lavender },
    Dimmed = { fg = C.overlay1 },
    Directory = { fg = C.blue },
    EndOfBuffer = { fg = C.surface1 },
    ErrorMsg = { fg = C.red, style = "bold,italic" },
    FoldColumn = { fg = C.overlay0 },
    Folded = { fg = C.blue, bg = C.surface1 },
    IncSearch = { fg = C.mantle, bg = "#7ec9d8" }, -- darken(sky, 0.90, base)
    LineNr = { fg = C.surface1 },
    MatchParen = { fg = C.peach, bg = "#393b4d", style = "bold" }, -- darken(surface1, 0.70, base)
    ModeMsg = { fg = C.text, style = "bold" },
    MoreMsg = { fg = C.blue },
    MsgSeparator = { link = "WinSeparator" },
    NonText = { fg = C.overlay0 },
    Normal = { fg = C.text, bg = C.base },
    NormalNC = { fg = C.text, bg = C.base },
    NormalSB = { fg = C.text, bg = C.crust },
    -- kitty only subjects a cell to `background_opacity` when its bg color
    -- exactly matches kitty's own `background` (COLORSCHEME.bg == kitty's
    -- base00) -- mantle keeps floats opaque, matching official NormalFloat.
    NormalFloat = { fg = C.text, bg = C.mantle },
    FloatBorder = { fg = C.blue, bg = C.mantle },
    FloatTitle = { fg = C.subtext0, bg = C.mantle },
    Pmenu = { fg = C.text, bg = C.mantle },
    PmenuSbar = { bg = C.surface0 },
    PmenuSel = { bg = C.surface0, style = "bold" },
    PmenuThumb = { bg = C.overlay0 },
    Question = { fg = C.blue },
    QuickFixLine = { bg = "#393b4d", style = "bold" },
    Search = { fg = C.text, bg = "#3e5767" }, -- darken(sky, 0.30, base)
    SignColumn = { fg = C.surface1 },
    SpecialKey = { link = "NonText" },
    StatusLine = { fg = C.text, bg = C.mantle },
    StatusLineNC = { fg = C.surface1, bg = C.mantle },
    Substitute = { fg = C.pink, bg = C.surface1 },
    TabLine = { fg = C.overlay0, bg = C.crust },
    TabLineFill = { bg = C.mantle },
    TabLineSel = { link = "Normal" },
    TermCursor = { fg = C.base, bg = C.rosewater },
    TermCursorNC = { fg = C.base, bg = C.overlay2 },
    Title = { fg = C.blue, style = "bold" },
    VertSplit = { fg = C.crust },
    Visual = { bg = C.surface1 },
    VisualNOS = { bg = C.surface1, style = "bold" },
    WarningMsg = { fg = C.yellow },
    Whitespace = { fg = C.surface1 },
    WildMenu = { bg = C.overlay0 },
    WinSeparator = { fg = C.crust },
    lCursor = { fg = C.base, bg = C.rosewater },

    -- Diff (backgrounds = official darken(color, ratio, base) precomputed)
    DiffAdd = { bg = "#364143" },
    DiffChange = { bg = "#313953" },
    DiffDelete = { bg = "#443244" },
    DiffText = { bg = "#4b6e7d" },
    Added = { fg = C.green },
    Changed = { fg = C.blue },
    Removed = { fg = C.red },
    diffAdded = { fg = C.green },
    diffRemoved = { fg = C.red },
    diffChanged = { fg = C.blue },
    diffOldFile = { fg = C.yellow },
    diffNewFile = { fg = C.peach },
    diffFile = { fg = C.blue },
    diffLine = { fg = C.overlay0 },
    diffIndexLine = { fg = C.teal },

    -- Syntax
    Boolean = { fg = C.peach },
    Character = { fg = C.teal },
    Comment = { fg = C.overlay2, style = "italic" },
    Conditional = { fg = C.mauve, style = "italic" },
    Constant = { fg = C.peach },
    Debug = { link = "Special" },
    Define = { link = "PreProc" },
    Delimiter = { fg = C.overlay2 },
    Exception = { fg = C.mauve },
    Float = { link = "Number" },
    Function = { fg = C.blue },
    Identifier = { fg = C.flamingo },
    Include = { fg = C.mauve },
    Keyword = { fg = C.mauve },
    Label = { fg = C.sapphire },
    Macro = { fg = C.mauve },
    Number = { fg = C.peach },
    Operator = { fg = C.sky },
    PreCondit = { link = "PreProc" },
    PreProc = { fg = C.pink },
    Repeat = { fg = C.mauve },
    Special = { fg = C.pink },
    SpecialChar = { link = "Special" },
    SpecialComment = { link = "Special" },
    Statement = { fg = C.mauve },
    StorageClass = { fg = C.yellow },
    String = { fg = C.green },
    Structure = { fg = C.yellow },
    Tag = { fg = C.lavender, style = "bold" },
    Todo = { fg = C.base, bg = C.flamingo, style = "bold" },
    Type = { fg = C.yellow },
    Typedef = { link = "Type" },
    Underlined = { style = "underline" },
    Bold = { style = "bold" },
    Italic = { style = "italic" },
    Error = { fg = C.red },
    qfLineNr = { fg = C.yellow },
    qfFileName = { fg = C.blue },
    htmlH1 = { fg = C.pink, style = "bold" },
    htmlH2 = { fg = C.blue, style = "bold" },
    mkdCodeDelimiter = { fg = C.text, bg = C.base },
    mkdCodeStart = { fg = C.flamingo, style = "bold" },
    mkdCodeEnd = { fg = C.flamingo, style = "bold" },

    -- Diagnostics
    DiagnosticError = { fg = C.red },
    DiagnosticWarn = { fg = C.peach },
    DiagnosticInfo = { fg = C.sky },
    DiagnosticHint = { fg = C.subtext0 },
    DiagnosticOk = { fg = C.green },
    DiagnosticUnderlineError = { style = "undercurl", guisp = C.red },
    DiagnosticUnderlineWarn = { style = "undercurl", guisp = C.peach },
    DiagnosticUnderlineInfo = { style = "undercurl", guisp = C.sky },
    DiagnosticUnderlineHint = { style = "undercurl", guisp = C.subtext0 },

    -- Plugin-specific (only groups for plugins actually installed)
    GitSignsAdd = { fg = C.green },
    GitSignsChange = { fg = C.yellow },
    GitSignsDelete = { fg = C.red },

    -- Custom captures (videoscript DSL)
    ["@vjv_embed"] = { bg = C.mantle },
    ["@lsp.mod.annotation"] = { fg = C.peach },

    -- Treesitter captures: official catppuccin/nvim groups/treesitter.lua
    -- with the option machinery flattened to mocha's default styles
    -- (comments/conditionals italic, miscs italic). Markdown rainbow heading
    -- links are not included -- their palette layout no longer ships one;
    -- headings use @markup.heading.
    ["@variable"] = { fg = C.text },
    ["@variable.builtin"] = { fg = C.red },
    ["@variable.parameter"] = { fg = C.maroon },
    ["@variable.member"] = { fg = C.lavender },
    ["@constant"] = { link = "Constant" },
    ["@constant.builtin"] = { fg = C.peach },
    ["@constant.macro"] = { link = "Macro" },
    ["@module"] = { fg = C.yellow, style = "italic" },
    ["@label"] = { link = "Label" },
    ["@string"] = { link = "String" },
    ["@string.documentation"] = { fg = C.teal },
    ["@string.regexp"] = { fg = C.pink },
    ["@string.escape"] = { fg = C.pink },
    ["@string.special"] = { link = "Special" },
    ["@string.special.path"] = { link = "Special" },
    ["@string.special.symbol"] = { fg = C.flamingo },
    ["@string.special.url"] = { fg = C.blue, style = "italic,underline" },
    ["@punctuation.delimiter.regex"] = { link = "@string.regexp" },
    ["@character"] = { link = "Character" },
    ["@character.special"] = { link = "SpecialChar" },
    ["@boolean"] = { link = "Boolean" },
    ["@number"] = { link = "Number" },
    ["@number.float"] = { link = "Float" },
    ["@type"] = { link = "Type" },
    ["@type.builtin"] = { fg = C.mauve },
    ["@type.definition"] = { link = "Type" },
    ["@attribute"] = { link = "Constant" },
    ["@property"] = { fg = C.lavender },
    ["@function"] = { link = "Function" },
    ["@function.builtin"] = { fg = C.peach },
    ["@function.call"] = { link = "Function" },
    ["@function.macro"] = { fg = C.pink },
    ["@function.method"] = { link = "Function" },
    ["@function.method.call"] = { link = "Function" },
    ["@constructor"] = { fg = C.yellow },
    ["@operator"] = { link = "Operator" },
    ["@keyword"] = { link = "Keyword" },
    ["@keyword.modifier"] = { link = "Keyword" },
    ["@keyword.type"] = { link = "Keyword" },
    ["@keyword.coroutine"] = { link = "Keyword" },
    ["@keyword.function"] = { fg = C.mauve },
    ["@keyword.operator"] = { fg = C.mauve },
    ["@keyword.import"] = { link = "Include" },
    ["@keyword.repeat"] = { link = "Repeat" },
    ["@keyword.return"] = { fg = C.mauve },
    ["@keyword.debug"] = { link = "Exception" },
    ["@keyword.exception"] = { link = "Exception" },
    ["@keyword.conditional"] = { link = "Conditional" },
    ["@keyword.conditional.ternary"] = { link = "Operator" },
    ["@keyword.directive"] = { link = "PreProc" },
    ["@keyword.directive.define"] = { link = "Define" },
    ["@keyword.export"] = { fg = C.mauve },
    ["@punctuation.delimiter"] = { link = "Delimiter" },
    ["@punctuation.bracket"] = { fg = C.overlay2 },
    ["@punctuation.special"] = { link = "Special" },
    ["@comment"] = { link = "Comment" },
    ["@comment.documentation"] = { link = "Comment" },
    ["@comment.error"] = { fg = C.base, bg = C.red },
    ["@comment.warning"] = { fg = C.base, bg = C.yellow },
    ["@comment.hint"] = { fg = C.base, bg = C.blue },
    ["@comment.todo"] = { fg = C.base, bg = C.flamingo },
    ["@comment.note"] = { fg = C.base, bg = C.rosewater },
    ["@markup"] = { fg = C.text },
    ["@markup.strong"] = { fg = C.red, style = "bold" },
    ["@markup.italic"] = { fg = C.red, style = "italic" },
    ["@markup.strikethrough"] = { fg = C.text, style = "strikethrough" },
    ["@markup.underline"] = { link = "Underlined" },
    ["@markup.heading"] = { fg = C.blue },
    ["@markup.heading.markdown"] = { style = "bold" },
    ["@markup.math"] = { fg = C.blue },
    ["@markup.quote"] = { fg = C.pink },
    ["@markup.environment"] = { fg = C.pink },
    ["@markup.environment.name"] = { fg = C.blue },
    ["@markup.link"] = { fg = C.lavender },
    ["@markup.link.label"] = { fg = C.lavender },
    ["@markup.link.url"] = { fg = C.blue, style = "italic,underline" },
    ["@markup.raw"] = { fg = C.green },
    ["@markup.list"] = { fg = C.teal },
    ["@markup.list.checked"] = { fg = C.green },
    ["@markup.list.unchecked"] = { fg = C.overlay1 },
    ["@diff.plus"] = { link = "diffAdded" },
    ["@diff.minus"] = { link = "diffRemoved" },
    ["@diff.delta"] = { link = "diffChanged" },
    ["@tag"] = { fg = C.blue },
    ["@tag.builtin"] = { fg = C.blue },
    ["@tag.attribute"] = { fg = C.yellow, style = "italic" },
    ["@tag.delimiter"] = { fg = C.teal },
    ["@error"] = { link = "Error" },
    ["@function.builtin.bash"] = { fg = C.red, style = "italic" },
    ["@variable.parameter.bash"] = { fg = C.green },
}

local function apply_highlights()
    vim.cmd("hi clear")
    if vim.fn.exists("syntax_on") == 1 then
        vim.cmd("syntax reset")
    end
    vim.o.termguicolors = true
    vim.g.colors_name = "catppuccin_mocha"

    for group, settings in pairs(highlights) do
        local command = "highlight " .. group
        if settings.link then
            command = "highlight link " .. group .. " " .. settings.link
        else
            if settings.fg then command = command .. " guifg=" .. settings.fg end
            if settings.bg then command = command .. " guibg=" .. settings.bg end
            if settings.style then command = command .. " gui=" .. settings.style end
            if settings.guisp then command = command .. " guisp=" .. settings.guisp end
        end
        vim.cmd(command)
    end

    -- Terminal colors: official catppuccin/nvim groups/terminal.lua map
    vim.g.terminal_color_0 = C.overlay0
    vim.g.terminal_color_1 = C.red
    vim.g.terminal_color_2 = C.green
    vim.g.terminal_color_3 = C.yellow
    vim.g.terminal_color_4 = C.blue
    vim.g.terminal_color_5 = C.pink
    vim.g.terminal_color_6 = C.sky
    vim.g.terminal_color_7 = C.text
    vim.g.terminal_color_8 = C.overlay1
    vim.g.terminal_color_9 = C.red
    vim.g.terminal_color_10 = C.green
    vim.g.terminal_color_11 = C.yellow
    vim.g.terminal_color_12 = C.blue
    vim.g.terminal_color_13 = C.pink
    vim.g.terminal_color_14 = C.sky
    vim.g.terminal_color_15 = C.text
    vim.g.terminal_color_background = C.base
    vim.g.terminal_color_foreground = C.text
end

apply_highlights()

-- Additional config
vim.cmd [[
    set fillchars=fold:\ ,vert:\│,eob:\ ,msgsep:‾,diff:╱
]]
