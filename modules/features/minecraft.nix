{inputs, ...}: {
  flake.nixosModules.minecraft = {
    config,
    pkgs,
    ...
  }: {
    services.minecraft-server = {
      enable = true;
      eula = true; # Vous devez accepter la licence Mojang
      declarative = true;
      jvmOpts = "-Xms2G -Xmx6G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true";
      package = pkgs.papermc;
      serverProperties = {
        server-port = 25565;
        gamemode = "survival";
        motd = "Mon Serveur NixOS";
        max-players = 15;
        view-distance = 16;
      };
    };
  };
}
