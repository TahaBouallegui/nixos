{ self, inputs, ... }:
{
  flake.nixosModules.grocy =
    { pkgs, ... }:
    {
      services.grocy = {
        enable = true;
        hostName = "grocy.tld";
        settings = {
          currency = "EUR";
          culture = "fr";
        };
      };
    };
}
