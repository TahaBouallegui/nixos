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
    
    services.xserver.virtualScreen = {
      x = 1920;
      y = 1080;
    };
    
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
