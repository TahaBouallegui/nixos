{ inputs, ... }: {
  flake.nixosModules.flatpak = { config, ... }: {
    imports = [
      inputs.flatpaks.nixosModules.default
    ];

    services.flatpak = {
      enable = true;

      remotes = {
        "GeForceNOW" =
          "https://international.download.nvidia.com/GFNLinux/flatpak/geforcenow.flatpakrepo";

        "flathub" =
          "https://dl.flathub.org/repo/flathub.flatpakrepo";

        "elyprismlauncher-origin" =
          "https://elyprismlauncher.github.io/flatpak/elyprismlauncher.flatpakref";
      };

      packages = [
        "GeForceNOW:app/com.nvidia.geforcenow/x86_64/master"
        "elyprismlauncher-origin:app/io.github.elyprismlauncher.ElyPrismLauncher/x86_64/stable"
      ];
    };
  };
}
