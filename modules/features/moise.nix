{
  flake.nixosModules.faker =
    { pkgs, config, ... }:
    {
      services.immich = {
        enable = true;
        port = 2283;
        host = "0.0.0.0";
        openFirewall = true;
        mediaLocation = "/var/lib/immich";

        # `null` gives access to all devices, including /dev/nvidia* nodes
        accelerationDevices = null;
      };

      users.users.immich.extraGroups = [
        "video"
        "render"
      ];
    };
}
