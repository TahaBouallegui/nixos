{
  flake.nixosModules.moonlight = {pkgs, ...}: {
    environment.systemPackages = [
      pkgs.moonlight-qt
      pkgs.tigervnc
    ];
  };
}
