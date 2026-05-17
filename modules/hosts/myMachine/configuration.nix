# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.myMachineConfiguration = {
    config,
    pkgs,
    ...
  }: {
    imports = [
      # Include the results of the hardware scan.
      self.nixosModules.myMachineHardware

      self.nixosModules.pkgs-stable

      self.nixosModules.base
      
      self.nixosModules.moonlight

      self.nixosModules.sddm
      self.nixosModules.desktop
    ];


  boot = {
    # Kernel Panic on suspend fix, taken from ArchLinux wiki.
    kernelParams = [
      "acpi_enforce_resources=lax"
      "i915.enable_dc=0"
    ];
    # Audio Mute LED
    extraModprobeConfig = ''
      options snd-hda-intel model=mute-led-gpio
    '';
  };
    nix.settings = {
      #Enabling flakes
      experimental-features = ["nix-command" "flakes"];
      
      # Nix Limit parallel build
      max-jobs = 12;
      cores = 12;
    };

    # Bootloader.
    boot.loader = {
      grub = {
        enable = true;
        efiSupport = true;
        device = "nodev";
      };
      efi.canTouchEfiVariables = true;
    };

    boot.kernelPackages = pkgs.linuxPackages_latest;

   # boot.kernelParams = [
   #   "nvidia_drm.modeset=1"
   #   "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
   # ];

    networking.hostName = "nixos"; # Define your hostname.
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

    # 1. Enable the service and the firewall
    services.tailscale = {
      enable = true;
    };
    networking.nftables.enable = true;
    networking.firewall = {
      enable = true;
      # Always allow traffic from your Tailscale network
      trustedInterfaces = ["tailscale0"];
      # Allow the Tailscale UDP port through the firewall
      allowedUDPPorts = [config.services.tailscale.port];
    };

    # 2. Force tailscaled to use nftables (Critical for clean nftables-only systems)
    # This avoids the "iptables-compat" translation layer issues.
    systemd.services.tailscaled.serviceConfig.Environment = [
      "TS_DEBUG_FIREWALL_MODE=nftables"
    ];

    # 3. Optimization: Prevent systemd from waiting for network online
    # (Optional but recommended for faster boot with VPNs)
    systemd.network.wait-online.enable = false;
    boot.initrd.systemd.network.wait-online.enable = false;

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
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      #media-session.enable = true;
    };

    # Define a user account. Don't forget to set a password with ‘paf.
    users.users.atb = {
      isNormalUser = true;
      description = "atb";
      extraGroups = ["networkmanager" "wheel" "dialout"];
    };

    services = {
      desktopManager.plasma6.enable = true;
    };

    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;


    services.xserver.videoDrivers = [ "nvidia" "intel" ];

    hardware = {
      graphics = {
        enable = true;
        enable32Bit = true;
        extraPackages = with pkgs; [
            intel-media-driver
        ];
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
        nvidiaBusId = "PCI:2@0:0:0";
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
    # services.openssh.enable = true;

    # Open ports in the firewall.
    # networking.firewall.allowedTCPPorts = [ ... ];
    # networking.firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "25.11"; # Did you read the comment?
  };
}
