{ self, inputs, ... }:
{
  flake.nixosModules.llama =
    { config, pkgs-stable, ... }:
    let
      llamaCppCuda = pkgs-stable.llama-cpp.override {
        cudaSupport = true;
      };
    in
    {
      nixpkgs.config.cudaSupport = true;
      nix.settings = {
        substituters = [ "https://cache.nixos-cuda.org" ];
        trusted-public-keys = [ "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M=" ];
      };

      environment.systemPackages = [
        llamaCppCuda
      ];
    };
}
