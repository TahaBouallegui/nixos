{ ... }:
{
  flake.nixosModules.samba =
    { ... }:
    {
      users.groups.share = { };
      users.users.share = {
        isSystemUser = true;
        group = "share";
        description = "Samba-only account for the shared network drive";
        # No NixOS-managed password -- Samba keeps its own separate password
        # database (passdb.tdb), there's no clean declarative story for it.
        # Set once after first activation: `sudo smbpasswd -a share`
      };

      systemd.tmpfiles.rules = [
        "d /srv/share 0775 share share -"
      ];

      # `bind interfaces only` + an interface that doesn't exist yet at smbd
      # startup makes smbd silently skip it and bind only to what *is*
      # present (lo) -- no error, no crash, just quietly unreachable over
      # tailscale. Order after the actual tailscale0 device unit (not just
      # tailscaled.service -- the daemon being "active" doesn't mean the
      # interface has appeared yet) so this race can't happen. Soft
      # dependency (wants+after, not requires/bindsTo) so a later tailscale0
      # flap doesn't take smbd down with it.
      systemd.services.samba-smbd = {
        after = [ "sys-subsystem-net-devices-tailscale0.device" ];
        wants = [ "sys-subsystem-net-devices-tailscale0.device" ];
      };

      services.samba = {
        enable = true;
        # Tailnet-only on purpose, same posture as jellyfin/grocy/searxng
        # this session: bound only to tailscale0 + lo, so there's nothing to
        # even firewall -- structurally unreachable off the tailnet, not just
        # filtered.
        openFirewall = false;
        # nmbd (legacy NetBIOS name broadcast/browsing, "Network
        # Neighborhood") relies on L2 broadcast, which tailscale0 (a
        # point-to-point tunnel interface) doesn't support -- it hangs on
        # startup past the systemd timeout and gets killed. Not needed: the
        # client mounts by hostname directly (SMB2/3 + DNS), no NetBIOS
        # involved. winbindd (AD/NT domain NSS integration) is equally
        # unused here -- local Unix users only.
        nmbd.enable = false;
        winbindd.enable = false;
        settings = {
          global = {
            workgroup = "WORKGROUP";
            "server string" = "lingangu";
            "netbios name" = "lingangu";
            "bind interfaces only" = true;
            interfaces = "tailscale0 lo";
          };
          share = {
            path = "/srv/share";
            browseable = "yes";
            "read only" = "no";
            "guest ok" = "no";
            "valid users" = "share";
            "force group" = "share";
            "create mask" = "0664";
            "directory mask" = "0775";
          };
        };
      };
    };
}
