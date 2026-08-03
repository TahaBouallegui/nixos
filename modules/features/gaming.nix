{ self, inputs, ... }: {
  flake.nixosModules.gaming =
    { pkgs-stable, ... }:
    {
      nix.settings = {
        substituters = [
          "https://prismlauncher.cachix.org"
        ];
        trusted-public-keys = [
          "prismlauncher.cachix.org-1:9/n/FGyABA2jLUVfY+DEp4hKds/rwO+SCOtbOkDzd+c="
        ];
      };
      nixpkgs.overlays = [ inputs.pineconemc.overlays.default ];
      environment.systemPackages = [
        pkgs-stable.prismlauncher
      ];
    };
}
