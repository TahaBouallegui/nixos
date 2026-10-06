{ self, ... }:
{
  # Not currently imported by any host (see robotechServer/configuration.nix,
  # commented out there). The module itself is real and builds fine, but
  # unlike every other self-hosted service in this repo it can't be made
  # to serve HTTPS purely declaratively:
  #   - Jellyfin's NixOS module has no TLS option at all -- no
  #     sslCertificate-style knob to set, so the cert/key have to be
  #     configured at runtime through Jellyfin's own admin dashboard
  #     (Dashboard > Networking), not through this file.
  #   - that dashboard also wants a password-protected PKCS#12 (.pfx)
  #     bundle, not the raw PEM cert/key every other service here uses, so
  #     it needs its own conversion step (below) rather than just pointing
  #     at self.tailscaleCert directly.
  #   - net effect: bringing this host up to the same "https everywhere"
  #     state as the rest of robotechServer requires a one-time manual
  #     step in Jellyfin's own UI that `nixos-rebuild switch` can't do for
  #     you, which is why it's parked here instead of wired in. Re-import
  #     it once that's acceptable; the automation below (systemd.paths
  #     watching the shared cert) still does the one part that *can* be
  #     automated.
  flake.nixosModules.jellyfin =
    { pkgs, ... }:
    {
      services.jellyfin = {
        enable = true;
        # Tailnet-only on purpose -- no raw WAN ports. Reachable via
        # trustedInterfaces = [ "tailscale0" ] (see tailscale.nix) instead.
        openFirewall = false;
      };

      # Jellyfin's NixOS module has no TLS option at all -- unlike every
      # other service here, its HTTPS listener is configured at runtime
      # through its own admin dashboard (Dashboard > Networking), and it
      # wants a password-protected PKCS#12 (.pfx) bundle, not raw PEM
      # cert/key files. This rebuilds that bundle from the shared
      # Tailscale cert whenever it renews; the one remaining manual step
      # (done once) is pointing Jellyfin's dashboard at the result:
      #   Certificate path: /var/lib/jellyfin/tailscale.pfx
      #   Certificate password: jellyfin
      #   Enable HTTPS, HTTPS port: 8920 (Jellyfin's own conventional port)
      systemd.services.jellyfin-tls-pfx = {
        description = "Rebuild the PKCS#12 bundle Jellyfin needs from the Tailscale cert";
        after = [ "tailscale-cert-renew.service" ];
        serviceConfig.Type = "oneshot";
        script = ''
          ${pkgs.openssl}/bin/openssl pkcs12 -export \
            -out /var/lib/jellyfin/tailscale.pfx \
            -inkey ${self.tailscaleCert.keyFile} \
            -in ${self.tailscaleCert.certFile} \
            -passout pass:jellyfin
          chown jellyfin:jellyfin /var/lib/jellyfin/tailscale.pfx
        '';
      };

      # Triggers once on every cert renewal rather than its own separate
      # timer -- PathChanged fires when the key file tailscale-cert-renew
      # just wrote is modified.
      systemd.paths.jellyfin-tls-pfx = {
        wantedBy = [ "multi-user.target" ];
        pathConfig.PathChanged = self.tailscaleCert.keyFile;
      };
    };
}
