{
  # bat needs no generated palette: it ships the official Catppuccin Mocha
  # theme built in, so the wrapper config just points at it by name -- the
  # palette stays defined once in modules/features/theme.nix and this line
  # is a reference to it, not a copy of it.
  flake.wrappersModules.bat =
    { ... }:
    {
      "bat-config".content = ''
        --theme "Catppuccin Mocha"
      '';
    };
}
