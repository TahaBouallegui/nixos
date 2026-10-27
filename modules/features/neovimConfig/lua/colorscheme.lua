-- Catppuccin Mocha palette, official hexes from the catppuccin/palette repo
-- (https://catppuccin.com/palette). Canonical color names first; the alias
-- blocks keep existing consumers (lualine.lua, after/ftplugin/videoscript.lua)
-- and the flake-side slot palette in modules/features/theme.nix readable
-- side by side.
local M = {
    rosewater = "#f5e0dc",
    flamingo = "#f2cdcd",
    pink = "#f5c2e7",
    mauve = "#cba6f7",
    red = "#f38ba8",
    maroon = "#eba0ac",
    peach = "#fab387",
    yellow = "#f9e2af",
    green = "#a6e3a1",
    teal = "#94e2d5",
    sky = "#89dceb",
    sapphire = "#74c7ec",
    blue = "#89b4fa",
    lavender = "#b4befe",
    text = "#cdd6f4",
    subtext1 = "#bac2de",
    subtext0 = "#a6adc8",
    overlay2 = "#9399b2",
    overlay1 = "#7f849c",
    overlay0 = "#6c7086",
    surface2 = "#585b70",
    surface1 = "#45475a",
    surface0 = "#313244",
    base = "#1e1e2e",
    mantle = "#181825",
    crust = "#11111b",
}

-- base00..0F slots mirroring flake.theme (modules/features/theme.nix).
M.base00 = M.base
M.base01 = M.mantle
M.base02 = M.surface0
M.base03 = M.surface1
M.base04 = M.overlay2
M.base05 = M.subtext1
M.base06 = M.text
M.base07 = M.text
M.base08 = M.red
M.base09 = M.peach
M.base0A = M.yellow
M.base0B = M.green
M.base0C = M.teal
M.base0D = M.blue
M.base0E = M.pink
M.base0F = M.pink

-- Legacy named aliases.
M.cyan = M.teal
M.blue2 = M.sapphire
M.bg = M.base
M.fg = M.text
M.orange = M.peach
M.magenta = M.pink
M.gray = M.surface2
M.lightgray = M.surface1
M.darkgray = M.mantle
M.inactivegray = M.crust

return M
