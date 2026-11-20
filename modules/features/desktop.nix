{self, ...}: {
  flake.nixosModules.desktop = {pkgs, ...}: let
    selfpkgs = self.packages."${pkgs.stdenv.hostPlatform.system}";
  in {
    imports = [
      self.nixosModules.flatpak
      self.nixosModules.librewolf
      self.nixosModules.noctalia
      self.nixosModules.pkgs-stable
    ];

    programs.niri.enable = true;
    programs.niri.package = selfpkgs.desktop;

    # noctalia itself arrives via self.nixosModules.noctalia
    # (programs.noctalia.package) and is started by niri's spawn-at-startup.
    environment.systemPackages = [
      selfpkgs.terminal
      pkgs.libreoffice
      pkgs.heroic
      pkgs.proton-vpn
      pkgs.prusa-slicer
      pkgs.orca-slicer
      pkgs.mpv
      pkgs.burpsuite
      pkgs.kicad
      pkgs.tutanota-desktop
      pkgs.pdfarranger
      pkgs.papers # PDF/document viewer (libadwaita); owns application/pdf below
      pkgs.zathura # kept for keyboard-first skimming, no longer the pdf default
      pkgs.qview
      # Cursor theme; one output holding all 12 variants, and niri picks
      # Bibata-Modern-Ice (see features/niri.nix).
      pkgs.bibata-cursors

      # xdg-open target for folders: the flake's configured yazi wrapper
      # (selfpkgs.yazi, the same one features/fish.nix binds) inside a kitty
      # window (selfpkgs.terminal, the configured kitty wrapper). NixOS has no
      # `xdg.desktopEntries` option -- that is home-manager -- so a
      # makeDesktopItem in systemPackages is the declarative way to get a
      # .desktop file xdg-mime can resolve. NoDisplay keeps it out of menus;
      # the pin below is what makes it the handler.
      (pkgs.makeDesktopItem {
        name = "org.atb.yazi";
        desktopName = "Yazi";
        genericName = "File Manager";
        comment = "Open the folder in yazi, inside kitty";
        exec = "${pkgs.lib.getExe selfpkgs.terminal} --class yazi --title yazi ${pkgs.lib.getExe selfpkgs.yazi} %f";
        tryExec = pkgs.lib.getExe selfpkgs.terminal;
        icon = "system-file-manager";
        categories = [
          "System"
          "FileManager"
        ];
        mimeTypes = ["inode/directory"];
        noDisplay = true;
        startupWMClass = "yazi";
      })
    ];

    # Plasma6 (Okular, Gwenview, Ark, ...) and niri-side apps (pdfarranger,
    # zathura, qview, mpv, ...) both register MIME claims with nothing
    # picking a winner, so resolution falls to arbitrary tiebreaking -- e.g.
    # every image and every PDF opening in pdfarranger. Pin the ones that
    # matter. System-level (not user-level), so it only fills gaps:
    # anything already set in ~/.config/mimeapps.list (e.g. the browser
    # associations) wins.
    environment.etc."xdg/mimeapps.list".text = ''
      [Default Applications]
      image/png=com.interversehq.qView.desktop
      image/jpeg=com.interversehq.qView.desktop
      image/gif=com.interversehq.qView.desktop
      image/bmp=com.interversehq.qView.desktop
      image/tiff=com.interversehq.qView.desktop
      image/webp=com.interversehq.qView.desktop
      image/svg+xml=com.interversehq.qView.desktop
      image/x-portable-pixmap=com.interversehq.qView.desktop
      image/x-portable-bitmap=com.interversehq.qView.desktop
      image/x-portable-graymap=com.interversehq.qView.desktop
      image/x-icon=com.interversehq.qView.desktop
      image/x-tga=com.interversehq.qView.desktop
      application/pdf=org.gnome.Papers.desktop
      # Nothing pins inode/directory, so xdg-mime falls through to
      # mimeinfo.cache, whose first candidate for it is kitty-open.desktop
      # (`Exec=kitty +open %U`, NoDisplay=true, MimeType lists inode/directory).
      # kitty has no directory handler, so "open the containing folder" -- e.g.
      # dsh's present-card button -- spawns a terminal whose child immediately
      # fails. Point it at the yazi entry defined above instead (Dolphin stays
      # installed via plasma6, just not as the handler).
      inode/directory=org.atb.yazi.desktop
      video/mp4=mpv.desktop
      video/x-matroska=mpv.desktop
      video/webm=mpv.desktop
      video/quicktime=mpv.desktop
      video/mpeg=mpv.desktop
      video/x-msvideo=mpv.desktop
      audio/mpeg=mpv.desktop
      audio/flac=mpv.desktop
      audio/ogg=mpv.desktop
      audio/x-wav=mpv.desktop
      application/x-bittorrent=org.qbittorrent.qBittorrent.desktop
    '';

    fonts.packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      ubuntu-sans
      cm_unicode
      corefonts
      unifont
      dejavu_fonts
      roboto
    ];

    fonts.fontconfig.defaultFonts = {
      serif = ["Ubuntu Sans"];
      sansSerif = ["Ubuntu Sans"];
      monospace = ["JetBrainsMono Nerd Font"];
    };

    time.timeZone = "Europe/Paris";
    i18n.defaultLocale = "en_US.UTF-8";
    i18n.extraLocaleSettings = {
      LC_ADDRESS = "fr_FR.UTF-8";
      LC_IDENTIFICATION = "fr_FR.UTF-8";
      LC_MEASUREMENT = "fr_FR.UTF-8";
      LC_MONETARY = "fr_FR.UTF-8";
      LC_NAME = "fr_FR.UTF-8";
      LC_NUMERIC = "fr_FR.UTF-8";
      LC_PAPER = "fr_FR.UTF-8";
      LC_TELEPHONE = "fr_FR.UTF-8";
      LC_TIME = "fr_FR.UTF-8";
    };

    services.upower.enable = true;

    security.polkit.enable = true;

    hardware = {
      bluetooth.enable = true;
      bluetooth.powerOnBoot = true;
    };
  };
}
