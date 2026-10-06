{ self, inputs, ... }:
{
  # Not currently imported by any host (see robotechServer/configuration.nix,
  # commented out there). The module itself is real and builds fine, but
  # its HTTPS setup has a real wrinkle: this is the one service whose
  # existing port was 80, and https:// doesn't default to port 80 the way
  # http:// does, so "same port, just https" (the rule every other service
  # here follows) means visiting it requires typing the port explicitly --
  # https://lingangu.tail5481a4.ts.net:80 -- instead of just the bare
  # hostname, which is a worse experience than what grocy had before this
  # change. Parked here until that's resolved (e.g. moving it to a
  # dedicated port instead of reusing 80) rather than shipping the
  # regression. Re-import once decided.
  flake.nixosModules.grocy =
    { pkgs, ... }:
    {
      services.grocy = {
        enable = true;
        hostName = "grocy.tld";
        # "grocy.tld" isn't a real, publicly resolvable domain, so ACME can
        # never issue a cert for it -- services.grocy defaults nginx.enableSSL
        # to true, which otherwise unconditionally forces ACME+HTTPS on this
        # vhost and fails on every activation. TLS is still enabled below,
        # just via the shared Tailscale cert instead of ACME.
        nginx.enableSSL = false;
        settings = {
          currency = "EUR";
          culture = "fr";
        };
      };

      # Same port as always (80) -- just https now. Note this means typing
      # the port explicitly (https://host:80), since 80 isn't the default
      # https port browsers assume; that's the one wrinkle to keeping every
      # service's port number unchanged.
      services.nginx.virtualHosts."grocy.tld" = {
        onlySSL = true;
        listen = [
          {
            addr = "0.0.0.0";
            port = 80;
            ssl = true;
          }
        ];
        sslCertificate = self.tailscaleCert.certFile;
        sslCertificateKey = self.tailscaleCert.keyFile;
      };
    };
}
