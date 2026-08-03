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

        self.nixosModules.pkgs-stable
      ];
      
      programs.ladybird.enable = true;
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
        pkgs.thunderbird
        pkgs.burpsuite
        pkgs.remmina
        pkgs.kicad
      ];

      programs.steam.enable = true;
      nixpkgs.overlays = [
        (final: prev: {
          steam = prev.steam.override {
            extraArgs = "-cef-disable-gpu-compositing";
          };
        })
      ];

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
