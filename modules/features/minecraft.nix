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
          package = pkgs.fabricServers.fabric-1_21_11;
          serverProperties = {
            server-port = 25565;
            difficulty = "normal";
            motd = "Halal minecraft server";
            max-players = 20;
            "enable-command-block" = true;
            view-distance = 16;
          };

          jvmOpts = "-Xms2G -Xmx4G";

        #  symlinks = {
        #    "mods" = pkgs.linkFarmFromDrvs "mods" (
        #  builtins.attrValues {
        #    Fabric-API = pkgs.fetchurl {
        #      url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/5zJNhXV2/fabric-api-0.141.4%2B1.21.11.jar";
        #      sha512 ="c092d48c6453bec3264f80f6a35bb334aba3112b5cd6c0e0b2676ce4d81e702cb1e522337f3a732348e757cc2226da3c601a314ae8766334f16af71a13bcc98d";
        #    };
        #  }
        #  );
        #};
      };
    };
  };
}
