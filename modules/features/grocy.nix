{ self, inputs, ... }:
{
  flake.nixosModules.grocy =
    { pkgs, ... }:
    {
      services.grocy = {
        enable = true;
        settings = {
          currency = "EUR";
          hostName = "grocy.tld";
          culture = "fr";
        };
      };
    };
}
