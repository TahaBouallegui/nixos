{ inputs, ... }: {
  flake.nixosModules.flatpak = { config, ... }: {
    imports = [
      inputs.flatpak.nixosModules.default
    ];

    services.flatpak = {
      enable = true;

      remotes = {
        "flathub" =
          "https://dl.flathub.org/repo/flathub.flatpakrepo";

        "GeForceNOW" =
          "https://international.download.nvidia.com/GFNLinux/flatpak/geforcenow.flatpakrepo";

        #"elyprismlauncher-origin" =
          #"https://elyprismlauncher.github.io/flatpak/elyprismlauncher.flatpakref";
      };

      packages = [
        "GeForceNOW:app/com.nvidia.geforcenow/x86_64/master"
        #"elyprismlauncher-origin:app/io.github.elyprismlauncher.ElyPrismLauncher/x86_64/stable"
      ];
    };
  };
}
