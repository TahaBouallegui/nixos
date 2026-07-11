{ self, inputs, ... }: {
  flake.nixosModules.sunshine =
    {
      config,
      pkgs,
      ...
    }:
    {
      services.xserver = {
        enable = true;
        desktopManager.gnome.enable = true;
        displayManager.gdm.enable = true;
      };

      services.xrdp.enable = true;
      services.gnome.gnome-remote-desktop.enable = true;
      services.xrdp.defaultWindowManager = "${pkgs.gnome-session}/bin/gnome-session";
      services.xrdp.openFirewall = true;

      hardware.uinput.enable = true;
      users.users.za3ter.extraGroups = [ "uinput" ];

      services.sunshine = {
        enable = true;
        autoStart = true;
        openFirewall = true;
        package = pkgs.sunshine.override {
          cudaSupport = true;
        };
      };

      programs.steam = {
        enable = true;
        extraCompatPackages = [ pkgs.dwproton-bin ];
      };

    };
}
