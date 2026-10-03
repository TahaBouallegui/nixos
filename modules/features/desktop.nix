{
  self,
  ...
}:
{
  flake.nixosModules.desktop =
    {
      pkgs,
      ...
    }:
    let
      selfpkgs = self.packages."${pkgs.stdenv.hostPlatform.system}";
    in
    {
      imports = [
        self.nixosModules.flatpak
        self.nixosModules.librewolf
        #self.nixosModules.zen-browser

        self.nixosModules.pkgs-stable
      ];
      
      programs.niri.enable = true;
      programs.niri.package = selfpkgs.desktop;

      preferences.autostart = [ selfpkgs.noctalia-shell ];

      environment.systemPackages = [
        selfpkgs.terminal
        pkgs.pcmanfm
        selfpkgs.noctalia-shell
        pkgs.libreoffice
        pkgs.heroic
        pkgs.proton-vpn 
        pkgs.prusa-slicer
        pkgs.orca-slicer
        pkgs.cutter
        pkgs.twitch-hls-client
        pkgs.mpv
        pkgs.qbittorrent
        pkgs.eden
        pkgs.burpsuite
        pkgs.remmina
        pkgs.kicad
        pkgs.tutanota-desktop
        pkgs.pdfarranger
        pkgs.zathura
        pkgs.qview
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
        application/pdf=org.pwmt.zathura-pdf-mupdf.desktop
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
        serif = [ "Ubuntu Sans" ];
        sansSerif = [ "Ubuntu Sans" ];
        monospace = [ "JetBrainsMono Nerd Font" ];
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
