{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.sunshine = {
    config,
    pkgs,
    ...
  }: {
    # auto‑login
    services.greetd = {
      enable = true;
      settings = {
        defualt_session = {
          command = "${pkgs.cage}/bin/cage -s -- ${pkgs.steam}/bin/steam -bigpicture";
          user = "za3ter";
        };
      };
    };
    # No need for Xorg
    services.xserver.enable = true;

    users.users.za3ter = {
      extraGroups = ["uinput"];
      isNormalUser = true;
    };
    hardware.uinput.enable = true;

    services.sunshine = {
      enable = true;
      autoStart = true;
      capSysAdmin = true;
      openFirewall = true;
    };

    programs.steam = {
      enable = true;
      extraCompatPackages = [pkgs.proton-ge-bin];
    };
  };
}
