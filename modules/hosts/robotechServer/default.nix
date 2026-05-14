{
  self,
  inputs,
  ...
}: {
  flake.nixosConfigurations.robotechServer = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.robotechServerConfiguration
    ];
  };
}
