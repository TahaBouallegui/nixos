{...}: {
  flake.nixosModules.noctalia = {...}: {
    programs.noctalia.enable = true;
  };
}
