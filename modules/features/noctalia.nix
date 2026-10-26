{
  ...
}:
{
  # Noctalia v5 (native runtime), base install only -- the v4 wrapper-modules
  # config is retired; runtime tweaks go through the shell's own Settings and
  # persist in ~/.local/state/noctalia/settings.toml, outside Nix's reach.
  # Current nixpkgs ships both the programs.noctalia module and the package,
  # and hydra prebuilds it -- no flake input, no extra substituter needed.
  flake.nixosModules.noctalia =
    { ... }:
    {
      programs.noctalia = {
        # recommendedServices stays off: no host here runs NetworkManager, so
        # silently enabling it would change networking.
        enable = true;
      };
    };
}
