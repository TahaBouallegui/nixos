{
  self,
  inputs,
  ...
}: {
  flake.nixosConfigurations.amal = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.amalConfiguration
    ];
  };
}
