{ inputs, ... }: {
  flake.nixosModules.minecraft =
    {
      pkgs,
      ...
    }:
    {
      imports = [ inputs.nix-minecraft.nixosModules.minecraft-servers ];
      nixpkgs.overlays = [ inputs.nix-minecraft.overlay ];

      services.minecraft-servers = {
        enable = true;
        eula = true; # Accept Minecraft EULA

        servers.my-fabric-server = {
          enable = true;
          package = pkgs.fabricServers.fabric-1_21;
          serverProperties = {
            server-port = 25565;
            difficulty = "normal";
            motd = "Halal minecraft server";
            max-players = 20;
            "enable-command-block" = true;
            view-distance = 16;
          };

          jvmOpts = "-Xms2G -Xmx4G";

          symlinks = {
            "mods" = ./mods;
          };
        };
      };
    };
}
