# nixos
My nixos configuration

## microVMs on robotechServer

robotechServer hosts two NixOS microVMs (`vm1`, `vm2`) managed declaratively with
[microvm.nix](https://github.com/microvm-nix/microvm.nix) in hub mode
(`modules/features/microvms.nix`): 1 vCPU / 2047 MiB each
(exactly 2048 triggers a qemu boot hang, microvm.nix #171), qemu hypervisor,
built inside the host's system closure.

### Golden rule

**The host owns the guests.** A guest's entire config lives in
`modules/features/microvms.nix`. To change one: edit that file and
`sudo nixos-rebuild switch --flake .#robotechServer` **on the host** — a changed
guest is reinstalled and restarted gracefully as part of the rebuild.

**Never run `nixos-rebuild switch` inside a guest.** It will appear to work,
but it writes a rival system profile into the guest while the host keeps
booting its own build: next reboot or rebuild silently reverts everything and
you end up with config split-brain. Same goes for editing files in `/etc` for
anything you care about — `/etc` is regenerated from the host config at every
boot. If you want it to stick, put it in the host module.

### Connecting

From the server itself:

```sh
microvm -r vm1                      # serial console (root / microvm — bootstrap only)
microvm -s vm1                      # ssh over vsock, no network involved
ssh -p 2201 admin@127.0.0.1         # vm1 over TCP, loopback only (vm2: 2202)
```

From any tailnet machine: `ssh -J za3ter@lingangu -p 2201 admin@localhost`.

`admin` authenticates with the pubkeys in `guestKeys` (in the module;
your `id_ed25519` is wired in). Root ssh login is `prohibit-password`; the
`microvm` password only exists for console bootstrap — change it with
`passwd root` after first login.

### What survives a reboot

Guest root is tmpfs — **only these paths persist** (they are disk volumes
under `/var/lib/microvms/<name>/` on the host):

| Path | Volume | Size |
|---|---|---|
| `/var/**` (NixOS state, host keys, profiles, data) | `drive-var.img` | 8 GiB |
| `/home/**` (user files) | `drive-home.img` | 8 GiB |
| `/nix/store` writes → overlay | `drive-rw-store.img` | 16 GiB |

Everything else — `/etc`, `/tmp`, anything you drop at `/`, installed
software's state outside `/var` — is gone on next boot. Write files to your
home, not `/root`.

### Using a guest day-to-day

- Imperative installs are fine and persist: `nix profile install nixpkgs#htop`.
- Quick experiments anywhere are fine *as long as you accept they evaporate*.
- The guest OS and its packages update when the host updates: guests are built
  from the host's nixpkgs input, so `nix flake update` + host rebuild is also
  the guest update mechanism (`nixos-version` in a guest matches the host).
- Ballooning is enabled: the host can reclaim guest RAM under memory pressure.

### Stopping / restarting

- `poweroff` or `reboot` inside a guest: the VM **comes back on its own**
  (the `microvm@<name>` unit is `Restart = "always"`). That's a feature —
  guests are meant to be always-on.
- Really stop one (e.g. to work on it): `sudo systemctl stop microvm@vm1`
  on the host — that's a graceful ACPI shutdown.
- Restart on demand: `sudo systemctl restart microvm@vm1`.

### Networking

qemu SLIRP **user-mode on purpose**: outbound internet works, the guests are
*not* visible on the LAN, and no host bridge/networkd setup is touched.
Inbound only where explicitly forwarded — currently loopback `2201`/`2202`
→ guest ssh. To expose a service on the host, add a `forwardPorts` entry in
the module and rebuild the host; want it on your tailnet instead? Enable
`services.tailscale.enable` inside the guest config (needs an auth key).

### Removing a guest

Delete its entry from `guests` in the module + host rebuild: the services go
away but the state is kept. Nuke the data deliberately with
`sudo rm -rf /var/lib/microvms/<name>` on the host.
