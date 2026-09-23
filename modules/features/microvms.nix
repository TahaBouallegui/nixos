{ inputs, ... }:
{
  # microVM fleet managed with microvm.nix (hub/host mode).
  #
  # Guests are NixOS systems built WITH the host system closure:
  # change a guest = edit its config here + rebuild the host.
  # Never run `nixos-rebuild switch` inside a guest; the host owns its config.
  #
  # Ops on the host:
  #   microvm -r <name>   serial console
  #   microvm -s <name>   ssh over vsock (no network config involved)
  #   ssh -p <sshPort> admin@127.0.0.1   host-local ssh
  #   state lives under /var/lib/microvms/<name>/
  flake.nixosModules.microvms =
    { config, lib, ... }:
    let
      # Pubkeys for the "admin" user inside every guest.
      guestKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINf5jZlfpKE7OVRo2u3c0Qy595Ul1VgoeIcXvhNPhcEC ahmedtbou@tutamail.com"
      ];

      # ==================================================================
      # GUEST REGISTRY - one block per VM.
      # This is where you configure a machine INDIVIDUALLY: put its
      # vm-specific NixOS config in `extra` (services, users, packages...).
      # Everything the guests share lives in mkGuest, further below.
      # ==================================================================
      guests = {
        # ------------------------------ vm1 ------------------------------
        vm1 = {
          # unique identity bits
          cid = 3; # vsock cid, must be unique per VM
          sshPort = 2201; # host loopback port -> guest ssh
          mac = "02:00:00:00:00:01";

          # >>> vm1-only NixOS config goes here <<<
          extra = {
            # e.g.: services.nginx.enable = true;
          };
        };

        # ------------------------------ vm2 ------------------------------
        vm2 = {
          cid = 4;
          sshPort = 2202;
          mac = "02:00:00:00:00:02";

          # >>> vm2-only NixOS config goes here <<<
          extra = {
            # e.g.: services.postgresql.enable = true;
          };
        };
      };

      # ==================================================================
      # SHARED BASE - hardware, network, persistence & access applied to
      # EVERY guest, then merged with that guest's `extra` block above.
      # ==================================================================
      mkGuest = name: { cid, sshPort, mac, ... }: {
        system.stateVersion = lib.trivial.release;
        networking.hostName = name;

        microvm = {
          # qemu: the one hypervisor with user networking + vsock + virtiofs
          hypervisor = "qemu";
          vcpu = 1;
          # 2048 exactly triggers a qemu boot hang (microvm.nix #171),
          # so: one MiB under the requested 2 GiB.
          mem = 2047;
          balloon = true;

          # SLIRP user networking: outbound works with zero host setup,
          # the host's NetworkManager/tailscale stay untouched.
          # Inbound only through forwardPorts below.
          interfaces = [ { type = "user"; id = "usr-${name}"; inherit mac; } ];

          # Share the host's store instead of baking one into every image.
          shares = [
            {
              proto = "virtiofs";
              tag = "ro-store";
              source = "/nix/store";
              mountPoint = "/nix/.ro-store";
            }
          ];

          # Persistence: writes to /nix/store land in the overlay volume,
          # NixOS state (/var: host keys, profiles, data) and /home in
          # their own volumes. Volumes are auto-created at first boot
          # under the state dir.
          writableStoreOverlay = "/nix/.rw-store";
          # Root is tmpfs: ONLY /var, /home and store writes (the overlay)
          # survive a reboot. Append new volumes at the END so existing
          # volume letters (vda, vdb, ...) stay stable.
          volumes = [
            # relative image names resolve under /var/lib/microvms/<name>/
            { image = "drive-rw-store.img"; mountPoint = "/nix/.rw-store"; size = 16384; }
            { image = "drive-var.img"; mountPoint = "/var"; size = 8192; }
            { image = "drive-home.img"; mountPoint = "/home"; size = 8192; }
          ];

          # `microvm -s <name>` from the host: ssh without any network.
          vsock.cid = cid;
          vsock.ssh.enable = true;

          # ssh from the host over TCP: bound to loopback only.
          forwardPorts = [
            {
              from = "host";
              host.address = "127.0.0.1";
              host.port = sshPort;
              guest.port = 22;
            }
          ];
        };

        # Default NixOS networkd unit runs DHCP on the slirp interface.
        systemd.network.enable = true;

        services.openssh = {
          enable = true;
          settings.PermitRootLogin = "prohibit-password";
        };

        users.users = {
          # Bootstrap only: log in on the console (root / microvm),
          # `passwd root`, then use admin over ssh.
          root.initialPassword = "microvm";
          admin = {
            isNormalUser = true;
            extraGroups = [ "wheel" ];
            openssh.authorizedKeys.keys = guestKeys;
          };
        };
      };
    in
    {
      imports = [ inputs.microvm.nixosModules.host ];

      # One module per guest: shared base, with the guest's own `extra`
      # deep-merged over it (`extra` wins on any leaf; note merging
      # REPLACES lists, so to add volumes/ports give the full list).
      # autostart on boot comes for free (microvm.vms.<name>.autostart = true)
      microvm.vms = lib.mapAttrs (name: spec: {
        config = lib.recursiveUpdate (mkGuest name spec) spec.extra;
      }) guests;
    };
}
