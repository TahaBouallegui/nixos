{ self, inputs, ... }:
{
  flake.nixosModules.ai =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.llama-cpp
        pkgs.koboldcpp
        pkgs.sillytavern
      ];
    };
}
