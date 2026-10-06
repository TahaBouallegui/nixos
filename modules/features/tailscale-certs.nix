{ ... }:
let
  tailscaleHostname = "lingangu.tail5481a4.ts.net";
  certDir = "/var/lib/tailscale-certs";
in
{
  # Cross-module data flow, same convention as self.theme/self.wallpaper --
  # any feature that fronts a service with nginx references these instead
  # of hardcoding paths.
  flake.tailscaleCert = {
    certFile = "${certDir}/${tailscaleHostname}.crt";
    keyFile = "${certDir}/${tailscaleHostname}.key";
  };

  flake.nixosModules.tailscale-certs =
    { config, pkgs, ... }:
    {
      systemd.tmpfiles.rules = [
        "d ${certDir} 0750 root ${config.services.nginx.group} -"
      ];

      # Tailscale issues real, browser-trusted Let's Encrypt certs for a
      # tailnet machine's own MagicDNS name (`tailscale cert`) -- but
      # unlike e.g. Caddy's built-in integration, nothing renews them
      # automatically; tailscaled has no way to know where a renewed cert
      # should go. Requires "HTTPS Certificates" enabled for the tailnet
      # first (https://login.tailscale.com/admin/dns), a one-time account
      # setting this can't express declaratively.
      systemd.services.tailscale-cert-renew = {
        description = "Renew the Tailscale-issued TLS cert for this host";
        after = [ "tailscaled.service" ];
        wants = [ "tailscaled.service" ];
        serviceConfig.Type = "oneshot";
        script = ''
          ${pkgs.tailscale}/bin/tailscale cert \
            --cert-file=${certDir}/${tailscaleHostname}.crt \
            --key-file=${certDir}/${tailscaleHostname}.key \
            ${tailscaleHostname}
          chmod 640 ${certDir}/${tailscaleHostname}.key
          chown root:${config.services.nginx.group} ${certDir}/${tailscaleHostname}.key
          systemctl reload nginx.service || true
        '';
      };

      systemd.timers.tailscale-cert-renew = {
        description = "Daily renewal check for the Tailscale TLS cert";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "daily";
          Persistent = true;
          RandomizedDelaySec = "1h";
        };
      };
    };
}
