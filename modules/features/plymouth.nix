{ self, inputs, ... }:
{
  flake.nixosModules.plymouth =
    { config, ... }:
    {
      boot = {
        plymouth = {
          enable = true;
        };

        # Enable "Silent boot" (boot.initrd.verbose dropped: scripted stage 1
        # was removed in nixpkgs 26.11)
        consoleLogLevel = 3;
        kernelParams = [
          "quiet"
          "rd.udev.log_level=3"
          "rd.systemd.show_status=auto"
        ];

        loader.timeout = 1;
      };
    };
}
