{ self, ... }:
{
  flake.nixosModules.nextcloud =
    { pkgs, ... }:
    let
      tailscaleHostname = "lingangu.tail5481a4.ts.net";
    in
    {
      services.nextcloud = {
        enable = true;
        package = pkgs.nextcloud35;
        hostName = "nextcloud.tld";
        home = "/var/lib/nextcloud";
        https = true;

        # sqlite -- no separate database service to run/back up for a
        # single-household instance. Fine to migrate to postgres later if
        # it's ever outgrown.
        #
        # adminuser/adminpassFile deliberately disabled (both must be null
        # together -- adminuser defaults to "root", not null, so it has to
        # be set explicitly): robotechServer isn't a sops recipient (only
        # amal is, see AGENTS.md), and onboarding it is a bigger, separate
        # decision than "add nextcloud". This does NOT present a friendly
        # first-run web wizard -- it leaves a fully-initialized instance
        # with zero accounts, and since Nextcloud never offers public
        # self-signup, there's no account-creation path through the web UI
        # at all in that state. Create the real admin account once, from
        # the server, after first activation:
        #   sudo -u nextcloud nextcloud-occ user:add --group=admin atb
        config = {
          dbtype = "sqlite";
          adminuser = null;
          adminpassFile = null;
        };

        settings = {
          # Nextcloud itself rejects requests whose Host header isn't
          # listed here ("untrusted domain"), independently of whatever
          # nginx lets through -- accessed by tailscale hostname/IP, not
          # by `hostName` above, so both need to be listed explicitly.
          trusted_domains = [
            tailscaleHostname
            "100.68.187.8"
          ];
        };
      };

      # grocy already owns the sole/default nginx vhost on port 80 (no
      # second vhost explicitly marked default_server) -- adding nextcloud
      # there risks nginx picking a new default and silently breaking
      # grocy's existing plain-IP access. Dedicated ports sidestep that
      # entirely, and match how every other service here is reached anyway
      # (searxng:8900, immich:2283, jellyfin:8096). Same port as always,
      # just https now -- cert/renewal come from the shared
      # tailscale-certs module (self.tailscaleCert).
      services.nginx.virtualHosts."nextcloud.tld" = {
        listen = [
          {
            addr = "0.0.0.0";
            port = 8099;
            ssl = true;
          }
        ];
        sslCertificate = self.tailscaleCert.certFile;
        sslCertificateKey = self.tailscaleCert.keyFile;
      };

      # Tailnet-only, same posture as every other self-hosted service this
      # session -- no openFirewall, no allowedTCPPorts. Reachable only via
      # trustedInterfaces (tailscale.nix).
    };
}
