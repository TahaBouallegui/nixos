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
    
    boot.kernelParams = [ "video=DP-1:1920x1080R@60D" ];
    
    hardware.uinput.enable = true;
    
    services.sunshine = {
      enable = true;
      autoStart = true; 
      openFirewall = true;
    };
    environment.systemPackages = with pkgs; [
    xorg.xrandr
    x11vnc
    ];
  };
}
