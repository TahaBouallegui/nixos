# NE MODIFIEZ PAS CE FICHIER! Il pourrait être généré par ‘nixos-generate-config’
# Cette configuration générée sera mise dans /etc/nixos/configuration.nix, elle peut
# être injectée directement dans ce fichier en cas de changement de hardware.
# Si vous voulez configurer le système, ajouter une module dans /etc/nixos/modules/features/
{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.robotechMachineHardware = {
    config,
    lib,
    pkgs,
    modulesPath,
    ...
  }: {
    imports = [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

    boot.initrd.availableKernelModules = ["xhci_pci" "ehci_pci" "ahci" "usb_storage" "usbhid" "ums_realtek" "sd_mod"];
    boot.initrd.kernelModules = [];
    boot.kernelModules = ["kvm-intel"];
    boot.extraModulePackages = [];

    fileSystems."/" = {
      device = "/dev/disk/by-uuid/5d250937-d09c-4d39-b0b9-1a63b1705798";
      fsType = "ext4";
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/E078-C1A1";
      fsType = "vfat";
      options = ["fmask=0077" "dmask=0077"];
    };

    swapDevices = [
      {device = "/dev/disk/by-uuid/8e473619-740c-47b1-a2ca-c7489d1b336d";}
    ];

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}
