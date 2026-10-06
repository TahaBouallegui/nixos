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
        # Also runs on every boot/activation (not just the daily timer
        # below) -- without this, a fresh machine/first activation has no
        # cert file yet, nginx's pre-start config test fails trying to
        # load a cert that doesn't exist, and nginx hits start-limit-hit
        # retrying before the timer ever gets a chance to fire.
        wantedBy = [ "multi-user.target" ];
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

      # Every nginx-fronted service here depends on the cert existing
      # before nginx's pre-start config test runs -- an explicit ordering
      # dependency, not just "the timer will probably have fired by now".
      systemd.services.nginx = {
        after = [ "tailscale-cert-renew.service" ];
        wants = [ "tailscale-cert-renew.service" ];
      };
    };
}
