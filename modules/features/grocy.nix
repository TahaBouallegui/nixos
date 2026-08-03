{ self, inputs, ... }:
{
  flake.nixosModules.grocy =
    { pkgs, ... }:
    {
      security.acme.acceptTerms = true;
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
