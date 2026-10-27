let
  theme = {
    base00 = "#1e1e2e"; # bg (mocha base)
    base01 = "#181825"; # dark (mantle)
    base02 = "#313244"; # surface0
    base03 = "#45475a"; # surface1
    base04 = "#9399b2"; # overlay2
    base05 = "#bac2de"; # subtext1
    base06 = "#cdd6f4"; # fg (text)
    base07 = "#cdd6f4"; # light fg (text)
    base08 = "#f38ba8"; # red
    base09 = "#fab387"; # orange (peach)
    base0A = "#f9e2af"; # yellow
    base0B = "#a6e3a1"; # green
    base0C = "#94e2d5"; # cyan (teal)
    base0D = "#89b4fa"; # blue
    base0E = "#f5c2e7"; # magenta (pink)
    base0F = "#f5c2e7"; # pink
  };

  stripHash = str:
    if builtins.substring 0 1 str == "#"
    then builtins.substring 1 (builtins.stringLength str - 1) str
    else str;

  themeNoHash = builtins.mapAttrs (_: v: stripHash v) theme;
in {
  flake = {
    inherit theme themeNoHash;
  };
}
