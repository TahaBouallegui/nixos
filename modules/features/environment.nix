{
  lib,
  inputs,
  self,
  ...
}: {
  perSystem = {
    pkgs,
    self',
    ...
  }: {
    # My whole desktop in one package, includes kityy terminal
    packages.desktop = inputs.wrapper-modules.wrappers.niri.wrap {
      inherit pkgs;
      imports = [self.wrappersModules.niri];
      terminal = lib.getExe self'.packages.terminal;
      env = {
        EDITOR = lib.getExe self'.packages.neovim;
      };
    };

    # My primary flake terminal
    packages.terminal =
      (inputs.wrappers.wrapperModules.kitty.apply {
        inherit pkgs;
        imports = [self.wrappersModules.kitty];
        shell = lib.getExe self'.packages.environment;
      }).wrapper;

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

        # other
        pkgs.file
        pkgs.unzip
        pkgs.zip
        pkgs.p7zip
        pkgs.wget
        pkgs.killall
        pkgs.sshfs
        pkgs.fzf
        (pkgs.btop.overrideAttrs (oldAttrs: {
            cmakeFlags = (oldAttrs.cmakeFlags or []) ++ [
            "-DBTOP_GPU=ON"
            ];
        }))
        pkgs.eza
        pkgs.fd
        pkgs.zoxide
        pkgs.dust
        pkgs.ripgrep
        pkgs.fastfetch
        pkgs.tree-sitter
        pkgs.imagemagick
        pkgs.imv
        pkgs.ffmpeg-full
        pkgs.yt-dlp
        pkgs.lazygit
        pkgs.texliveFull
        pkgs.tree
        pkgs.btop
        pkgs.cowsay
        pkgs.yazi

        pkgs.python3
        pkgs.python313Packages.dbus-python

        pkgs.gnumake
        pkgs.dfu-programmer
        pkgs.usbutils
        pkgs.gcc
        pkgs.minicom
        pkgs.SDL2
        pkgs.SDL2_ttf
        pkgs.libusb1
        pkgs.pkg-config

        #avr
        pkgs.avra
        pkgs.avrdude
        pkgs.pkgsCross.avr.buildPackages.gcc
        pkgs.pkgsCross.avr.buildPackages.binutils

        # wrapped
        self'.packages.neovim
        self'.packages.qalc
        self'.packages.git
      ];
    };
  };
}
