{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.robotechServerConfiguration = {
    config,
    pkgs,
    ...
  }: {
    imports = [
      # Rajoutez ici les modules que vous voulez voir dans le système
      self.nixosModules.robotechMachineHardware
      self.nixosModules.sunshine
      self.nixosModules.fixed-boot-date
    ];

    nix.settings.experimental-features = ["nix-command" "flakes"];

    # Bootloader.
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    networking.hostName = "lingangu"; # Define your hostname.
    # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

    # Configure network proxy if necessary
    # networking.proxy.default = "http://user:password@proxy:port/";
    # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # Enable networking
    networking.networkmanager.enable = true;

    services.tailscale.enable = true;
    networking.nftables.enable = true;
    networking.firewall = {
      enable = true;
      trustedInterfaces = ["tailscale0"];
      allowedUDPPorts = [config.services.tailscale.port];
    };
    systemd.services.tailscaled.serviceConfig.Environment = [
      "TS_DEBUG_FIREWALL_MODE=nftables"
    ];

    time.timeZone = "Europe/Paris";
    time.hardwareClockInLocalTime = false;

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

    # Configure keymap in X11
    services.xserver.xkb = {
      layout = "fr";
      variant = "";
    };

    # Configure console keymap
    console.keyMap = "fr";

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users = {
      #Ceux qui sont dans ce groupe peuvent acceder aux fichiers config et les manipuler sans sudo
      groups.nixos-config = {};

      users.za3ter = {
        isNormalUser = true;
        description = "za3ter";
        extraGroups = ["networkmanager" "wheel" "nixos-config" "video" "audio"];
        packages = with pkgs; [];
        shell = self.packages.${pkgs.system}.environment;
      };
      users.bobg = {
        isNormalUser = true;
        description = "president";
        extraGroups = ["networkmanager" "wheel" "nixos-config"];
        packages = with pkgs; [];
      };
      users.icarus = {
        isNormalUser = true;
        description = "indien";
        extraGroups = ["networkmanager" "wheel" "nixos-config"];
        packages = with pkgs; [];
      };
      users.kohm = {
        isNormalUser = true;
        description = "AI = Actually Indian";
        extraGroups = ["networkmanager" "wheel" "nixos-config"];
        packages = with pkgs; [];
      };
    };

    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = [
      pkgs.vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
      # On installe Python avec la bibliothèque nécessaire pour l'IA
      (pkgs.python3.withPackages (ps:
        with ps; [
          openai
        ]))
    ];

    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    programs.mtr.enable = true;
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    # X11 display with i3 and auto‑login
    services.xserver = {
      enable = true;
      desktopManager.xfce.enable = false;
      windowManager.i3.enable = true;
      displayManager.autoLogin = {
        enable = true;
        user = "za3ter";
      };
      displayManager.defaultSession = "none+i3";
    };

    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    hardware.nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
      modesetting.enable = true;
      powerManagement.enable = true;
      powerManagement.finegrained = true;
      open = false;
      nvidiaSettings = true;
    };
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    # Nvidia DRM modesetting (required for Sunshine / NVFBC)
    boot.kernelParams = [
      "nvidia_drm.modeset=1"
      "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
    ];
    # List services that you want to enable:

    # Enable the OpenSSH daemon.
    services.openssh.enable = true;
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
