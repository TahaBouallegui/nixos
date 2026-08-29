{ self, inputs, ... }: {
  flake.nixosModules.gaming =
    { pkgs, ... }:
    {
      nix.settings = {
        substituters = [
          "https://prismlauncher.cachix.org"
        ];
        trusted-public-keys = [
          "prismlauncher.cachix.org-1:9/n/FGyABA2jLUVfY+DEp4hKds/rwO+SCOtbOkDzd+c="
        ];
      };
      environment.systemPackages = [
        inputs.pineconemc.packages.${pkgs.system}.prismlauncher
      ];

      programs.steam.enable = true;
      programs.steam.extraCompatPackages = with pkgs; [
        proton-ge-bin
      ];

      programs.gamescope = {
        enable = true;
        capSysNice = true; # Recommended for real-time priority
      };
      programs.gamemode.enable = true;
    };
}
