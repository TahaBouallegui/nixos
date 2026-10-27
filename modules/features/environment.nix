{
  lib,
  inputs,
  self,
  ...
}:
{
  perSystem =
    {
      pkgs,
      self',
      ...
    }:
    {
      # My whole desktop in one package, includes kityy terminal
      packages.desktop = inputs.wrapper-modules.wrappers.niri.wrap {
        inherit pkgs;
        imports = [ self.wrappersModules.niri ];
        terminal = lib.getExe self'.packages.terminal;
        env = {
          EDITOR = lib.getExe self'.packages.neovim;

          NIXPKGS_ALLOW_UNFREE = "1";
        };
      };

      # My primary flake terminal
      packages.terminal =
        (inputs.wrappers.wrapperModules.kitty.apply {
          inherit pkgs;
          imports = [ self.wrappersModules.kitty ];
          shell = lib.getExe self'.packages.environment;
        }).wrapper;

      # bat/btop themed from the flake palette (modules/features/theme.nix)
      # -- wrapper bakes BAT_CONFIG_PATH / --config --themes-dir into the
      # executables, so the theme can't drift via user config dirs.
      packages.bat =
        (inputs.wrappers.wrapperModules.bat.apply {
          inherit pkgs;
          imports = [ self.wrappersModules.bat ];
        }).wrapper;

      packages.btop = inputs.wrapper-modules.wrappers.btop.wrap {
        inherit pkgs;
        imports = [ self.wrappersModules.btop ];
      };

      # My primary flake shell with all of it's packages
      packages.environment = inputs.wrappers.lib.wrapPackage {
        inherit pkgs;
        package = self'.packages.fish;
        runtimeInputs = [
          # nix
          pkgs.nil
          pkgs.nixd
          pkgs.statix
          pkgs.alejandra
          pkgs.manix
          pkgs.nix-inspect
          pkgs.nh

          # other
          pkgs.file
          pkgs.unzip
          pkgs.zip
          pkgs.p7zip
          pkgs.wget
          pkgs.killall
          pkgs.sshfs
          pkgs.fzf
          pkgs.eza
          pkgs.fd
          pkgs.zoxide
          pkgs.dust
          pkgs.ripgrep
          pkgs.tree-sitter
          pkgs.imagemagick
          pkgs.imv
          pkgs.ffmpeg-full
          pkgs.yt-dlp
          pkgs.lazygit
          pkgs.man-pages
          pkgs.tree
          pkgs.tldr
          pkgs.pstree
          pkgs.man-pages
          pkgs.man-pages-posix
          pkgs.wl-clipboard
          pkgs.opencode
          pkgs.wine

          # wrapped
          self'.packages.neovim
          self'.packages.qalc
          self'.packages.git
          self'.packages.yazi
          self'.packages.bat
          self'.packages.btop
        ];
      };
    };
}
