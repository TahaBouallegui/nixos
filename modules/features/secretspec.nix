{ ... }:
{
  flake.nixosModules.secretspec =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.secretspec
      ];
    };
}
