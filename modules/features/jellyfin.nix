{ ... }:
{
  flake.nixosModules.jellyfin =
    { ... }:
    {
      services.jellyfin = {
        enable = true;
        # Tailnet-only on purpose -- no raw WAN ports. Reachable via
        # trustedInterfaces = [ "tailscale0" ] (see tailscale.nix) instead.
        openFirewall = false;
      };
    };
}
