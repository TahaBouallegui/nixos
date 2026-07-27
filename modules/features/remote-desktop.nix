{ self, inputs, ... }:
{
  flake.nixosModules.remote-desktop =
    { pkgs, config, ... }:
    {

      services.xserver.enable = true;
      services.xserver.displayManager.gdm.enable = true;
      services.xserver.desktopManager.gnome.enable = true;

      services.gnome.gnome-remote-desktop.enable = true;

      services.xrdp.enable = true;
      services.xrdp.defaultWindowManager = "gnome-session";
      services.xrdp.openFirewall = true; 

      systemd.sleep.settings.Sleep = {
        AllowSuspend = "no";
        AllowHibernation = "no";
        AllowHybridSleep = "no";
        AllowSuspendThenHibernate = "no";
      };
    };
}
