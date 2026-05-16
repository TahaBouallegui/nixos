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
      desktopManager = {
        xterm.enable = false;
        xfce.enable = true;
      };
      displayManager.autoLogin = {
        enable = true;
        user = "za3ter";
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

    programs.steam = {
        enable = true;       
    };
  };
}
