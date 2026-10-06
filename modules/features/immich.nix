{ self, inputs, ... }:
{
  flake.nixosModules.immich =
    { config, ... }:
    let
      tailscaleHostname = "lingangu.tail5481a4.ts.net";
    in
    {
      services.immich = {
        enable = true;
        port = 2283;
        # Immich has no native TLS support (no cert/key options in its
        # module) -- bind it to localhost only and let nginx terminate TLS
        # in front of it, same port as before.
        host = "127.0.0.1";
        openFirewall = false;
        mediaLocation = "/var/lib/immich";

        # `null` gives access to all devices, including /dev/nvidia* nodes
        accelerationDevices = null;
      };

      users.users.immich.extraGroups = [
        "video"
        "render"
      ];

      services.nginx = {
        enable = true;
        # Distinct vhost key from searxng's -- searxng's key is forced to
        # literally be the tailscale hostname (its own `domain` option
        # doubles as the nginx attribute name internally), so reusing that
        # string here would merge the two vhosts into one and collide their
        # listen ports/locations. `serverName` carries the actual hostname
        # instead.
        virtualHosts."immich" = {
          serverName = tailscaleHostname;
          onlySSL = true;
          listen = [
            {
              addr = "0.0.0.0";
              port = 2283;
              ssl = true;
            }
          ];
          sslCertificate = self.tailscaleCert.certFile;
          sslCertificateKey = self.tailscaleCert.keyFile;
          locations."/" = {
            proxyPass = "http://127.0.0.1:2283";
            proxyWebsockets = true;
            recommendedProxySettings = true;
            # nginx's own default (1M) would otherwise cap uploads that
            # immich itself doesn't limit -- reverse-proxying introduces
            # this cap where none existed before.
            extraConfig = "client_max_body_size 0;";
          };
        };
      };
    };
}
