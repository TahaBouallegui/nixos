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
        # Tailnet-only on purpose, same posture as jellyfin/grocy/searxng
        # this session: bound only to tailscale0 + lo, so there's nothing to
        # even firewall -- structurally unreachable off the tailnet, not just
        # filtered.
        openFirewall = false;
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
