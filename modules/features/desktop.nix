{
  self,
  ...
}:
{
  flake.nixosModules.desktop =
    {
      pkgs,
      pkgs-stable,
      ...
    }:
    let
      selfpkgs = self.packages."${pkgs.stdenv.hostPlatform.system}";
    in
    {
      imports = [
        self.nixosModules.kicad
        self.nixosModules.flatpak
        self.nixosModules.librewolf

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
        pkgs.element-desktop
        pkgs.proton-vpn
        pkgs.prusa-slicer
        pkgs-stable.orca-slicer
        pkgs.freecad
        pkgs.cutter
        pkgs.twitch-hls-client
        pkgs.mpv
      ];

      programs.obs-studio = {
        enable = true;
      };

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
