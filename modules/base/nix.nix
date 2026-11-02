{ ... }:
{
  flake.nixosModules.nix =
    { ... }:
    {
      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];

      nix.gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 30d";
      };

      nixpkgs.config.allowUnfree = true;
      programs.nix-ld.enable = true;
    };
}
