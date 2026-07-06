{ self, inputs, ... }:
{
  flake.nixosModules.tailscale =
    { config, ... }:
    {

      services.tailscale = {
        enable = true;
        extraUpFlags = [
          #"--accept-routes=false" # Don't import routes from peers
          #"--accept-dns=false" # Don't override system DNS – Proton will handle it
          # If you ever need to use an exit node, you'd set --exit-node=... here,
          # but then you can't use Proton VPN simultaneously.
        ];
      };
      networking.nftables.enable = true;
      networking.firewall = {
        # Always allow traffic from your Tailscale network
        trustedInterfaces = [ "tailscale0" ];
        # Allow the Tailscale UDP port through the firewall
        allowedUDPPorts = [ config.services.tailscale.port ];
      };

      # 2. Force tailscaled to use nftables (Critical for clean nftables-only systems)
      # This avoids the "iptables-compat" translation layer issues.
      systemd.services.tailscaled.serviceConfig.Environment = [
        "TS_DEBUG_FIREWALL_MODE=nftables"
      ];
      # 3. Optimization: Prevent systemd from waiting for network online
      # (Optional but recommended for faster boot with VPNs)
      systemd.network.wait-online.enable = false;
      boot.initrd.systemd.network.wait-online.enable = false;

    };
}
