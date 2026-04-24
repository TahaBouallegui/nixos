# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
  
{ self, inputs, ... }:

{
  
  flake.nixosModules.myMachineConfiguration = { config, pkgs, ... }:

  {
    imports =
      [ # Include the results of the hardware scan.
        self.nixosModules.myMachineHardware

        self.nixosModules.base

        self.nixosModules.desktop
      ];
  
    nix.settings = 
    {
      #Enabling flakes
      experimental-features = [ "nix-command" "flakes" ];
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

    boot.kernelParams = [
      "nvidia_drm.modeset=1"
      "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
    ];
  
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
  
    # Enable the X11 windowing system.
    # You can disable this if you're only using the Wayland session.
    # services.xserver.enable = true;
  
    # Enable the KDE Plasma Desktop Environment.
    services.displayManager.sddm.enable = true;
    services.displayManager.sddm.wayland.enable = true;
    services.desktopManager.gnome.enable = true;
  
    # Configure keymap in X11
    services.xserver.xkb = {
      layout = "us";
      variant = "";
    };
  
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
  
    # Enable touchpad support (enabled default in most desktopManager).
    # services.xserver.libinput.enable = true;
  
    # Define a user account. Don't forget to set a password with ‘paf.
    users.users.atb = {
      isNormalUser = true;
      description = "atb";
      extraGroups = [ "networkmanager" "wheel" ];
      packages = with pkgs; [
        kdePackages.kate
        thunderbird
      ];
    };
  
    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;
  
    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [
    neovim
    librewolf
    element-desktop
    proton-vpn
    git
    tree
    btop
    pciutils
    ];
    
    services.xserver.videoDrivers = [
      "nvidia"
      "intel"
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
	        enableOffloadCmd = true;
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
    # networking.firewall.enable = false;
  
    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "25.11"; # Did you read the comment?
  
  };

}
