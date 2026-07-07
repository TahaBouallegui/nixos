# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  self,
  inputs,
  ...
}:
{
  flake.nixosModules.amalConfiguration =
    { config, pkgs, ... }:

    {
      imports = [
        # Include the results of the hardware scan.
        self.nixosModules.amalHardware

        self.nixosModules.pkgs-stable

        self.nixosModules.base

        #self.nixosModules.tailscale
        inputs.sops.nixosModules.sops

        self.nixosModules.moonlight
        self.nixosModules.sddm

        self.nixosModules.desktop
        self.nixosModules.gaming

        #inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t480
      ];

      # Bootloader.
      boot.loader = {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
      };

      boot = {
        plymouth = {
          enable = true;
        };

        # Enable 'silent boot' for a cleaner experience and to ensure
        # Plymouth is visible
        consoleLogLevel = 3;
        initrd.verbose = false;
        kernelParams = [
          "quiet"
          "splash"
          "boot.shell_on_fail"
          "udev.log_priority=3"
          "rd.systemd.show_status=auto"
        ];
      };

      # Use latest kernel.
      boot.kernelPackages = pkgs.linuxPackages_latest;

      nix = {
        settings = {
          experimental-features = [
            "nix-command"
            "flakes"
          ];
          max-jobs = 8;
          cores = 8;
        };

        gc = {
          automatic = true;
          dates = "weekly";
          options = "--delete-older-than 30d";
        };

      };

      networking.hostName = "amal"; # Define your hostname.
      # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

      # Configure network proxy if necessary
      # networking.proxy.default = "http://user:password@proxy:port/";
      # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

      # Enable networking
      networking.networkmanager.enable = true;


      # Set your time zone.
      time.timeZone = "Europe/Paris";

      # Select internationalisation properties.
      i18n.defaultLocale = "en_US.UTF-8";

      i18n.extraLocaleSettings = {
        LC_ADDRESS = "fr_FR.UTF-8";
        LC_IDENTIFICATION = "fr_FR.UTF-8";
        LC_MEASUREMENT = "fr_FR.UTF-8";
        LC_MONETARY = "fr_FR.UTF-8";
        LC_NAME = "fr_FR.UTF-8";
        LC_NUMERIC = "fr_FR.UTF-8";
        LC_PAPER = "fr_FR.UTF-8";
        LC_TELEPHONE = "fr_FR.UTF-8";
        LC_TIME = "fr_FR.UTF-8";
      };

      services.desktopManager.plasma6.enable = true;

      # Enable CUPS to print documents.
      services.printing.enable = true;

      # Enable sound with pipewire.
      services.pulseaudio.enable = false;
      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
      };

      users.users."atb" = {
        isNormalUser = true;
        description = "atb";
        extraGroups = [
          "networkmanager"
          "wheel"
        ];
        shell = self.packages.${pkgs.system}.environment;
      };

      nixpkgs.config.allowUnfree = true;

      services.xserver.videoDrivers = [
        "intel"
        "nvidia"
      ];

      hardware = {
        graphics = {
          enable = true;
          enable32Bit = true;
        };

        nvidia = {
          package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
          modesetting.enable = true;
          powerManagement.enable = true;
          powerManagement.finegrained = false;

          open = false;

          nvidiaSettings = true;

          prime = {
            offload = {
              enable = true;
            };
            intelBusId = "PCI:0@0:2:0";
            nvidiaBusId = "PCI:1@0:0:0";
          };
        };
      };

      # Some programs need SUID wrappers, can be configured further or are
      # started in user sessions.
      # programs.mtr.enable = true;
      # programs.gnupg.agent = {
      #   enable = true;
      #   enableSSHSupport = true;
      # };

      # List services that you want to enable:

      # Enable the OpenSSH daemon.
      services.openssh.enable = true;

      # Open ports in the firewall.
      # networking.firewall.allowedTCPPorts = [ ... ];
      # networking.firewall.allowedUDPPorts = [ ... ];
      # Or disable the firewall altogether.
      # networking.firewall.enable = false;

      # This value determines the NixOS release from which the default
      # settings for stateful data, like file locations and database versions
      # on your system were taken. It‘s perfectly fine and recommended to leave
      # this value at the release version of the first install of this system.
      # Before changing this value read the documentation for this option
      # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
      system.stateVersion = "26.05"; # Did you read the comment?

    };

}
