{
  flake.nixosModules.moonlight = { pkgs, ... }: {
    environment.systemPackages = [
      pkgs.moonlight-qt
    ];
    environment.sessionVariables = {
      LIBVA_DRIVER_NAME = "iHD";
    };
  };
}
