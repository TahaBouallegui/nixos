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
    
    boot.kernelParams = [ "video=DP-1:1920x1080@60" ];
    
    services.sunshine = {
      enable = true;
      autoStart = true; 
      openFirewall = true;
    };
  };
}
