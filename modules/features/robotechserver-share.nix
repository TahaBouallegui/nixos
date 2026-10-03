{ ... }:
{
  # Mounts robotechServer's /srv/share over the tailnet, always-on (not
  # browse-on-demand) -- shows up as a normal directory/drive, same as any
  # local disk. Needs `self.nixosModules.secrets` imported by the host.
  flake.nixosModules.robotechserver-share =
    { config, ... }:
    {
      sops.secrets."samba-share-password" = { };
      # `domain=` is required here even though the server has no real NT
      # domain (just workgroup = WORKGROUP) -- its absence is the single
      # most common cause of mount.cifs rejecting auth that smbclient
      # accepts fine, since the two tools negotiate differently.
      sops.templates."robotechserver-share-credentials".content = ''
        username=share
        password=${config.sops.placeholder."samba-share-password"}
        domain=WORKGROUP
      '';

      fileSystems."/mnt/robotechserver" = {
        device = "//lingangu.tail5481a4.ts.net/share";
        fsType = "cifs";
        options = [
          "credentials=${config.sops.templates."robotechserver-share-credentials".path}"
          "uid=1000"
          "gid=100"
          "vers=3.0"
          # kernel default since 3.8, but the whole point here is this
          # exact negotiation was failing -- make it explicit.
          "sec=ntlmssp"
          "_netdev"
          # mount on first access rather than blocking boot on an
          # unreachable tailnet host (e.g. the server being down)
          "x-systemd.automount"
          "noauto"
          "x-systemd.idle-timeout=60"
        ];
      };
    };
}
