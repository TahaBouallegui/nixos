{ self, flake, ... }:
{
  flake.nixosModules.searxng =
    { ... }:
    let
      tailscaleHostname = "lingangu.tail5481a4.ts.net";
    in
    {
      services.searx = {
        enable = true;
        redisCreateLocally = true;
        settings = {
          search.formats = [
            "html"
            "json"
          ];
        };

        # configureNginx fronts searx with nginx+uwsgi over a unix socket
        # instead of searx's own dev server -- same port as before (8900),
        # just terminated as real HTTPS now via the shared Tailscale cert.
        # `onlySSL` only exists so searx's own base_url auto-detection
        # (which checks onlySSL/addSSL/forceSSL, not raw `listen` entries)
        # emits "https://" instead of "http://" in its own settings.
        configureNginx = true;
        domain = tailscaleHostname;

        settings.server = {
          bind_address = "0.0.0.0";
          port = 8900;
          secret_key = "lingangu";
        };
      };

      services.nginx.virtualHosts."${tailscaleHostname}" = {
        onlySSL = true;
        listen = [
          {
            addr = "0.0.0.0";
            port = 8900;
            ssl = true;
          }
        ];
        sslCertificate = self.tailscaleCert.certFile;
        sslCertificateKey = self.tailscaleCert.keyFile;
      };
    };
}
