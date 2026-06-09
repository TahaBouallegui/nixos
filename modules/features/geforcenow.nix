{inputs, ...}: {
  flake.nixosModules.flatpak = {config, ...}: {
    imports = [
      inputs.flatpaks.nixosModules.default
    ];

    # Enable Flatpak support
    services.flatpak = {
      enable = true;

      # Add NVIDIA's GeForce NOW remote
      remotes = {
        "GeForceNOW" = "https://international.download.nvidia.com/GFNLinux/flatpak/geforcenow.flatpakrepo";
        # If you want Flathub for other apps, you can keep this
        "flathub" = "https://dl.flathub.org/repo/flathub.flatpakrepo";
        "prism" = "https://elyprismlauncher.github.io/flatpak/repo";
      };

      # Declare the GeForce NOW package
      packages = [
        "GeForceNOW:app/com.nvidia.geforcenow/x86_64-linux/master"
        "prism:app/org.prismlauncher.PrismLauncher/x86_64/stable"
        # Add any other flatpaks you may need here
      ];

      # Optional: Overrides for system integration
      overrides = {
        "com.nvidia.GeForceNow" = {
          context = {
            sockets = [
              "!x11"
            ];
          };
        };
      };
    };
  };
}
