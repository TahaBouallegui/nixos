{ inputs, ... }: {
  flake.nixosModules.minecraft =
    {
      pkgs,
      lib,
      ...
    }:
    {
      imports = [ inputs.flux.nixosModules.default ];
      nixpkgs.overlays = [ inputs.flux.overlays.default ];

      flux = {
        enable = true;
        servers.halalserver = {
          enable = false;
          package = pkgs.mkMinecraftServer {
            name = "HAHALminecraftserver";
            src = ./mcman;
            hash = "sha256-5DZyuiBqemIDVSyIjWJB1Qogg+hlIbQq1S+Ku1Eg/Tw=";
          };
        };
        servers.halaltensura = {
          enable = true;
          package = pkgs.mkMinecraftServer {
            name = "HAHALtensura";
            src = ./mcmantensura;
            hash = "sha256-mABEsPEW6JuUUA2RKPC+ZHGQeGkf8ClKZMGA1R2qT0Q=";
          };
        };
      };
    };
}
