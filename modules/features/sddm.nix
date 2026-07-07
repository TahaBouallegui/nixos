{ inputs, self, ... }:
{
  flake.nixosModules.sddm = {pkgs, ...}: let
    customized_sddm_astronaut = pkgs.sddm-astronaut.override {
      embeddedTheme = "pixel_sakura"; # The name of the theme you most loved
       themeConfig = {
          Background = "${self.lockscreen}"; # This theme also accepts videos
       };
    };
  in {
    environment.systemPackages = [
      customized_sddm_astronaut
    ];

    services.displayManager.defaultSession = "niri"; #FUCK gnome
    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
      extraPackages = [
        customized_sddm_astronaut # change the name of the package here to the one you created
      ];

      theme = "sddm-astronaut-theme"; # This remains the same because is the name of the theme, not the package
      settings = {
        Theme = {
          Current = "sddm-astronaut-theme"; # Remains the same
        };
      };
    };
  };
}
