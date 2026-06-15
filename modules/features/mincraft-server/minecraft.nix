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
          enable = true;
          package = pkgs.mkMinecraftServer {
            name = "HAHALminecraftserver";
            src = ./mcman;
            hash = "sha256-5DZyuiBqemIDVSyIjWJB1Qogg+hlIbQq1S+Ku1Eg/Tw=";
          };
        };
      };
    };
}
