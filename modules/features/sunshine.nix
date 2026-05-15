{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.sunshine = {
    config,
    pkgs,
    ...
  }: {

    # X11 display with i3 and auto‑login
    services.xserver = {
      enable = true;
      desktopManager.xfce.enable = false;
      windowManager.i3.enable = true;
      displayManager.autoLogin = {
        enable = true;
        user = "za3ter";
      };
      displayManager.defaultSession = "none+i3";
    };

    home-manager.users.za3ter = {pkgs, ... }: {
        config = {
            modifier = alt;
            "&{mod}+w" = "exec librewolf";
        };
    };

    imports = [
        self.nixosModules.librewolf
    ];
    
    hardware.uinput.enable = true;
    
    services.sunshine = {
      enable = true;
      autoStart = true; 
      openFirewall = true;
    };
    environment.systemPackages = with pkgs; [
    xrandr
    x11vnc
    ];
  };
}
