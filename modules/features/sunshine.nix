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
      desktopManager.xfce.enable = true;
      displayManager.lightdm.enable = true;
      displayManager.autoLogin = {
        enable = true;
        user = "za3ter";
      };
    };
    environment.etc."X11/xorg.conf.d/headless-virtual-display.conf".text = ''
  Section "ServerLayout"
      Identifier "TwinLayout"
      Screen 0 "metaScreen" 0 0
  EndSection

  Section "Monitor"``
      Identifier "Monitor0"
      Option "Enable" "true"
  EndSection

  Section "Device"
      Identifier "Card0"
      Driver "nvidia"
      VendorName "NVIDIA Corporation"
      Option "MetaModes" "1920x1080"
      Option "ConnectedMonitor" "DP-0"
      Option "ModeValidation" "NoDFPNativeResolutionCheck,NoVirtualSizeCheck,NoMaxPClkCheck,NoHorizSyncCheck,NoVertRefreshCheck,NoWidthAlignmentCheck"
  EndSection

  Section "Screen"
      Identifier "metaScreen"
      Device "Card0"
      Monitor "Monitor0"
      DefaultDepth 24
      Option "TwinView" "True"
      SubSection "Display"
          Modes "1920x1080"
      EndSubSection
  EndSection
'';
users.users.za3ter = {
  extraGroups = [ "uinput" ];
};
    hardware.uinput.enable = true;

    services.sunshine = {
      enable = true;
      autoStart = true; 
      openFirewall = true;
      capSysAdmin = true;
      package = pkgs.sunshine.override {
        cudaSupport = true;
      };
    };

    programs.steam = {
        enable = true;
        extraCompatPackages = [ pkgs.dwproton-bin ];
    };
  };
}
