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
        xfce.enable = true;
      };
      displayManager.autoLogin = {
        enable = true;
        user = "za3ter";
      };config = ''
  Section "Device"
      Identifier  "Nvidia Card"
      Driver      "nvidia"
      VendorName  "NVIDIA Corporation"
      Option      "AllowEmptyInitialConfiguration" "True"
      Option      "ConnectedMonitor" "DFP-0"
  EndSection
  Section "Screen"
      Identifier  "Default Screen"
      Device      "Nvidia Card"
      SubSection "Display"
          Depth    24
          Virtual  1920 1080
      EndSubSection
  EndSection
'';
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
        extraCompatPackages = [ pkgs.proton-ge-bin ];
    };
  };
}
