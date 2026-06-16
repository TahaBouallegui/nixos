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
        package = pkgs.mkMinecraftServer {
            name = "HAHAL MINECRAFT SERVER";
            src = ./mcman;
            hash = lib.fakeHash;
        };
      };
    };
}
