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

      # deepseek-harness (dsh) prebuilt binaries. Upstream publishes them to
      # its own cachix and declares it in that flake's nixConfig -- but nix
      # ignores an input's nixConfig entirely (only the flake given on the
      # command line is read, and even that only for trusted users). The
      # system nix.conf below is the one copy that works for every user and
      # for nixos-rebuild.
      nix.settings.extra-substituters = [ "https://deepseek-harness-nix.cachix.org" ];
      nix.settings.extra-trusted-public-keys = [
        "deepseek-harness-nix.cachix.org-1:5NrkwLN9veNMhiINtU5ZeV4isXFhFsOwn6Ms7J1M+TA="
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
