{ self, inputs, ... }:
{
  flake.nixosModules.grocy =
    { pkgs, ... }:
    {
      security.acme.acceptTerms = true;
      services.grocy = {
        enable = true;
        hostName = "grocy.ltd";
        settings = {
          currency = "EUR";
          culture = "fr";
        };
      };
      services.nginx.virtualHosts."grocy.ltd".listen = [
        {
          addr = "100.68.187.8";
          port = 8000;
        }
      ];
      networking.firewall.allowedTCPPorts = [ 8000 ];
    };
}
