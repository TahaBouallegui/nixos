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
    services.sunshine = {
      enable = true;
    };

    networking.firewall = {
      # Sunshine ports (TCP & UDP)
      allowedTCPPorts = [47984 47989 47990 48000];
      allowedUDPPortRanges = [
        {
          from = 47998;
          to = 48000;
        }
        {
          from = 47984;
          to = 47990;
        }
      ];
    };
  };
}
