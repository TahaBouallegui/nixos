{ inputs, ... }:
{
  flake.nixosModules.nixIndex =
    { ... }:
    {
      imports = [
        inputs.nix-index-database.nixosModules.default
      ];

      # weekly-updated prebuilt database instead of a local `nix-index` scan;
      # this is what backs `,` (comma, already on PATH via the `environment`
      # wrapped shell) -- without it, comma has no database to query at all.
      programs.nix-index-database.comma.enable = true;
    };
}
