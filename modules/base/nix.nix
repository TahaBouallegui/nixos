{ ... }:
{
  # Shared plumbing every host wants -- not a host-agnostic opt-in capability,
  # so this lives in base/ rather than features/, per AGENTS.md's own layering.
  # Deliberately excludes max-jobs/cores: those reflect each machine's actual
  # CPU core count (Amal/robotechServer: 4, myMachine: 12) and shouldn't be
  # silently homogenized.
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
    };
}
