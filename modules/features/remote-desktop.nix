{ self, inputs, ... }:
{
  flake.nixosModules.remote-desktop =
    { pkgs, config, ... }:
    {

      # Enable the X server and GNOME
      services.xserver.enable = true;
      services.xserver.desktopManager.gnome.enable = true;

      # Enable TigerVNC server
      services.tigervnc = {
        enable = true;
        display = 1; # Uses :1 (port 5901)
        geometry = "1920x1080"; # Adjust to your client resolution
        depth = 24;
        passwordFile = "/etc/vnc/passwd"; # File containing the VNC password

        # Optional: custom session command (GNOME is default if not set)
        # session = "gnome-session";
      };

      # Open the firewall for the VNC port
      networking.firewall.allowedTCPPorts = [ 5901 ];
      systemd.sleep.settings.Sleep = {
        AllowSuspend = "no";
        AllowHibernation = "no";
        AllowHybridSleep = "no";
        AllowSuspendThenHibernate = "no";
      };
    };
}
