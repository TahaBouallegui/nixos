{ self, inputs, ... }:
{
  flake.nixosModules.kvm-qemu =
    { config, pkgs, lib, ... }:
    {
      virtualisation.libvirtd = {
        enable = true;

        # qemu_kvm only emulates the host arch, saves disk space.
        # Use pkgs.qemu if you need alien-arch emulation.
        qemu = {
          package = lib.mkDefault pkgs.qemu_kvm;
          runAsRoot = lib.mkDefault true;
          swtpm.enable = true;
        };

        # nftables backend follows networking.nftables by default,
        # needed if you use tailscale.nix on the same host.
        # firewallBackend = lib.mkDefault "nftables";

        onBoot = lib.mkDefault "ignore";
        onShutdown = lib.mkDefault "suspend";
      };

      # libvirtd asserts this, desktop.nix already sets it,
      # keep it here so the module works standalone.
      security.polkit.enable = lib.mkDefault true;

      programs.virt-manager.enable = true;

      virtualisation.spiceUSBRedirection.enable = true;

      environment.systemPackages = with pkgs; [
        virt-viewer
        spice
        spice-gtk
        spice-protocol
        dnsmasq
        swtpm
        OVMF
      ];

      # Add your user to "libvirtd" to use virsh/virt-manager
      # without sudo, e.g. in your host configuration:
      #   users.users.atb.extraGroups = [ "libvirtd" ];
    };
}
