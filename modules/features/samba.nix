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

      services.samba = {
        enable = true;
        # Tailnet-only, same posture as jellyfin/grocy/searxng this session
        # -- but via `hosts allow`/`hosts deny` (below), not interface
        # binding. `bind interfaces only` structurally cannot work with
        # tailscale0: it's a point-to-point tunnel interface with no
        # broadcast capability, and Samba's interface-binding logic only
        # considers broadcast-capable interfaces -- smbd silently skips it
        # and binds only to lo, no error, no crash, just quietly
        # unreachable, no matter how `interfaces` is specified (name or
        # CIDR, confirmed both fail the same way). Known Samba limitation,
        # not a config mistake -- `hosts allow` is the documented fix.
        # openFirewall stays false regardless: the default-deny firewall
        # already blocks non-tailnet traffic to 445, this is a second,
        # application-level layer on top.
        openFirewall = false;
        # nmbd (legacy NetBIOS name broadcast/browsing, "Network
        # Neighborhood") relies on L2 broadcast, which tailscale0 doesn't
        # support either -- it hangs on startup past the systemd timeout
        # and gets killed. Not needed: the client mounts by hostname
        # directly (SMB2/3 + DNS), no NetBIOS involved. winbindd (AD/NT
        # domain NSS integration) is equally unused here -- local Unix
        # users only.
        nmbd.enable = false;
        winbindd.enable = false;
        settings = {
          global = {
            workgroup = "WORKGROUP";
            "server string" = "lingangu";
            "netbios name" = "lingangu";
            # Tailscale's full CGNAT allocation, plus loopback. "hosts
            # allow" is checked first and short-circuits to allow on a
            # match, so this correctly takes priority over "hosts deny".
            "hosts allow" = "100.64.0.0/10 127.0.0.1";
            "hosts deny" = "0.0.0.0/0";
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
