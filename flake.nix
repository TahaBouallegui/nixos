{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-26.05";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    import-tree.url = "github:vic/import-tree";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    wrappers.url = "github:Lassulus/wrappers";
    wrapper-modules = {
      url = "github:BirdeeHub/nix-wrapper-modules";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flatpak = {
      url = "github:in-a-dil-emma/declarative-flatpak/latest";
    };

    flux = {
      url = "github:iogamaster/flux";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    xilinx-nix-utils.url = "github:DLR-FT/xilinx-nix-utils";
    # pinned to PR #157 head (fix/riot-client-frameworks): only branch upstream
    # that fixes the Riot Client typing/click crashes (getrlimit RLIM_INFINITY
    # SIGILL, %rdx syscall garbage, missing AppKit methods) and reaches verified
    # gameplay; reverts to main once merged -> switch back to lucannez64/darling-lol.
    darling-lol.url = "github:oxakromax/darling-lol/dd17cf799d3b36487165ce93c45c536e38cfc610";

    microvm = {
      url = "github:microvm-nix/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pineconemc = {
      url = "github:ElyPrismLauncher/Launcher";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}
