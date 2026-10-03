{ inputs, ... }:
{
  # NOT imported by any host yet -- see the setup/removal notes below.
  # This is real, working infrastructure (fixes the previous broken attempt:
  # `pkgs.overlays` isn't a valid assignment there, `overlays.default` and
  # `pkgs.vivado` don't exist upstream), not a placeholder. It's just that:
  #   1. The ~100GB install needs a Xilinx/AMD account to download -- that
  #      step can never be made hermetic, no matter how this is packaged.
  #   2. It needs free disk space this machine doesn't currently have.
  #   3. Licensing (WebPACK vs. a real license file) is specific to your
  #      Xilinx account and device family -- nothing I can preconfigure.
  #
  # ## Setting it up (once you have the space)
  #
  # 1. Download the EXACT installer this flake's hash is pinned to --
  #    checked directly against xilinx-nix-utils' xilinx-unified.nix, not the
  #    README (which is stale/out of sync with its own pinned version):
  #      FPGAs_AdaptiveSoCs_Unified_SDI_2025.2.1_0320_0604.tar
  #    From https://www.amd.com/en/support/downloads/adaptive-socs-and-fpgas/development-tools/2025-2.html
  #    (an AMD/Xilinx account + EULA click-through is unavoidable here)
  #
  # 2. Add it to the Nix store:
  #      nix store add-file ~/Downloads/FPGAs_AdaptiveSoCs_Unified_SDI_2025.2.1_0320_0604.tar
  #    If the hash doesn't match what's pinned (e.g. AMD shipped a different
  #    build), `nix build` will print the real `requireFile` instructions
  #    with the exact fix needed -- follow that over this comment.
  #
  # 3. Add `self.nixosModules.vivado` to the host's `configuration.nix`
  #    imports, then `sudo nixos-rebuild switch --flake .#<host>`.
  #    First build compiles/unpacks the whole toolchain inside an FHS
  #    sandbox -- expect it to take a long while.
  #
  # 4. Licensing: Vivado still wants either a WebPACK-eligible device (free,
  #    no license file) or `XILINXD_LICENSE_FILE` pointed at a real license
  #    from your Xilinx account -- set up through the IDE itself on first
  #    run, same as on any other distro.
  #
  # Only need flashing/debugging, not synthesis? `xilinx-lab` (Vivado Lab
  # Edition, overlay `inputs.xilinx-nix-utils.overlays.xilinx-lab`, package
  # `pkgs.xilinx-lab`) is a much smaller install -- swap it in below instead.
  #
  # ## Getting rid of it completely
  #
  # 1. Remove `self.nixosModules.vivado` from the host's imports, rebuild.
  # 2. `nix-collect-garbage -d` -- once nothing in any generation references
  #    the toolchain or the installer tarball anymore, this reclaims the
  #    whole ~100GB on its own, no manual store-path hunting needed.
  # 3. Delete this file and the `xilinx-nix-utils` input from `flake.nix`.
  flake.nixosModules.vivado =
    { pkgs, ... }:
    {
      nixpkgs.overlays = [ inputs.xilinx-nix-utils.overlays.xilinx-unified ];
      environment.systemPackages = [ pkgs.xilinx-unified ];
    };
}
