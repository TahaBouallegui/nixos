{ self, inputs, ... }:
{
  self.nixosModules.nvidia =
    { config, pkgs, ... }:
    {
      nixpkgs.config.allowUnfree = true;

      nix.settings = {
        substituters = [
          "https://cache.nixos.org" # Official (free packages)
          "https://cache.nixos-cuda.org" # CUDA packages
          "https://nix-community.cachix.org" # Community CUDA/unfree
          "https://nixpkgs-unfree.cachix.org" # Unfree packages
          "https://cache.flox.dev" # Flox CUDA cache
          "https://cuda-maintainers.cachix.org"
        ];
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "nixpkgs-unfree.cachix.org-1:hqvoInulhbV4nJ9yJOEr+4wxhDV4xq2d1DK7S6Nj6rs="
          "flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs="
          "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
        ];
      };

      services.xserver.videoDrivers = [
        "nvidia"
      ];

      hardware = {
        graphics = {
          enable = true;
          enable32Bit = true;
        };

        nvidia = {
          package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
          modesetting.enable = true;
          powerManagement.enable = true;
          powerManagement.finegrained = false;

          open = false;

          nvidiaSettings = true;

          prime = {
            offload = {
              enable = true;
              enableOffloadCmd = true;
            };
          };
        };
      };
    };
}
