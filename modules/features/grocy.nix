{ self, inputs, ... }:
{
  flake.nixosModules.grocy =
    { pkgs, ... }:
    {
      services.grocy = {
        enable = true;
        hostName = "grocy.tld";
        # "grocy.tld" isn't a real, publicly resolvable domain, so ACME can
        # never issue a cert for it -- services.grocy defaults nginx.enableSSL
        # to true, which otherwise unconditionally forces ACME+HTTPS on this
        # vhost and fails on every activation. Plain HTTP is fine here:
        # reachable over the tailnet only (trustedInterfaces, see
        # tailscale.nix), same as jellyfin.
        nginx.enableSSL = false;
        settings = {
          currency = "EUR";
          culture = "fr";
        };
      };
    };
}
