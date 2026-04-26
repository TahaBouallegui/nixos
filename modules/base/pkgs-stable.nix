{ self, inputs, ... }:
{
  flake.nixosModules.pkgs-stable = { config, pkgs, ... }: {
    config._module.args.pkgs-stable = import inputs.nixpkgs-stable {
      system = config.nixpkgs.hostPlatform.system;
    };
  };
}