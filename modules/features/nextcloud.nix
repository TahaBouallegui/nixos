{ ... }:
{
  flake.nixosModules.nextcloud =
    { pkgs, ... }:
    {
      services.nextcloud = {
        enable = true;
        package = pkgs.nextcloud35;
        hostName = "nextcloud.tld";
        home = "/var/lib/nextcloud";
        https = false;

        # sqlite -- no separate database service to run/back up for a
        # single-household instance. Fine to migrate to postgres later if
        # it's ever outgrown.
        #
        # adminuser/adminpassFile deliberately disabled (both must be null
        # together -- adminuser defaults to "root", not null, so it has to
        # be set explicitly): robotechServer isn't a sops recipient (only
        # amal is, see AGENTS.md), and onboarding it is a bigger, separate
        # decision than "add nextcloud". Nextcloud's own first-run web
        # wizard handles admin creation instead, so no credential, not even
        # an encrypted one, has to live in this repo for it at all.
        config = {
          dbtype = "sqlite";
          adminuser = null;
          adminpassFile = null;
        };

        settings = {
          overwriteprotocol = "http";
          # Nextcloud itself rejects requests whose Host header isn't
          # listed here ("untrusted domain"), independently of whatever
          # nginx lets through -- accessed by tailscale hostname/IP, not
          # by `hostName` above, so both need to be listed explicitly.
          trusted_domains = [
            "lingangu.tail5481a4.ts.net"
            "100.68.187.8"
          ];
        };
      };

      # grocy already owns the sole/default nginx vhost on port 80 (no
      # second vhost explicitly marked default_server) -- adding nextcloud
      # there risks nginx picking a new default and silently breaking
      # grocy's existing plain-IP access. Dedicated port sidesteps that
      # entirely, and matches how every other service here is reached
      # anyway (searxng:8900, immich:2283, jellyfin:8096).
      services.nginx.virtualHosts."nextcloud.tld".listen = [
        {
          addr = "0.0.0.0";
          port = 8099;
        }
      ];

      # Tailnet-only, same posture as every other self-hosted service this
      # session -- no openFirewall, no allowedTCPPorts. Reachable only via
      # trustedInterfaces (tailscale.nix).
    };
}
