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
      displayManager.autoLogin = {
        enable = true;
        user = "za3ter";
      };
      windowManager.i3.enable = true;
      displayManager.defaultSession = "none+i3";
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
