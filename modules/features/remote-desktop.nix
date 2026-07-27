{ self, inputs, ... }:
{
  flake.nixosModules.remote-desktop =
    { pkgs, config, ... }:
    {

      # Enable GNOME
      services.xserver.enable = true;
      services.xserver.displayManager.gdm.enable = true;
      services.xserver.desktopManager.gnome.enable = true;

      # Enable GNOME Remote Desktop (RDP)
      services.gnome.gnome-remote-desktop.enable = true;

      # Open firewall port for RDP (default 3389)
      networking.firewall.allowedTCPPorts = [ 3389 ];
      systemd.sleep.settings.Sleep = {
        AllowSuspend = "no";
        AllowHibernation = "no";
        AllowHybridSleep = "no";
        AllowSuspendThenHibernate = "no";
      };
    };
}
