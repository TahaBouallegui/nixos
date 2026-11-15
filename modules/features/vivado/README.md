# Vivado on NixOS — imperative install (≈20 GB), declarative wrapper

Model: **AMD's own web installer** downloads and installs the toolchain (only
the components we select — Vivado ML Standard + Zynq-7000 — which is why the
download is ≈20 GB instead of the ≈150 GB full-edition default or the 96.89 GB
offline SFD tar). Nix never touches AMD's servers (impossible anyway: AMD
account + EULA click-through). Nix provides only:

- `self.packages.<system>.vivado` — an FHS wrapper (`vivado.nix` in this
  directory) that finds the installed tree at runtime and runs it.
- `self.nixosModules.vivado` — puts that wrapper in `environment.systemPackages`
  and installs the vendored FTDI udev rules. **Not imported by any host yet.**

Board under test: Digilent Arty Z7-20 (XC7Z020-1CLG400C, Zynq-7000 family,
covered by the free Vivado ML Standard / WebPACK tier — no license file needed).

Disk budget: 347 MB (`.bin`) + ~1 GB (extracted installer) + ~20 GB (components
the web installer stages while downloading) + the installed tree → keep
**~50 GB free**. Measured on this install: **52 GB** total
(`data` 19G, `tps` 9.4G, `Vivado` 7.3G, `lnx64` 5.5G, `gnu` 4.5G, `Vitis` 3.7G,
`xic` 542M). Check with `df -h /home`.

---

## Setup

1. **Get the web installer** — AMD account required.
   <https://www.amd.com/en/support/downloads/adaptive-socs-and-fpgas/development-tools/2025-2.html>
   Pick the *Self Extracting Web Installer* for Linux. The one in hand is
   `FPGAs_AdaptiveSoCs_Unified_SDI_2025.2_1114_2157_Lin64.bin` (347 MB; its
   banner reports `Branch: 2025.2`, build 2025-10-29). Do **not** grab the
   "Single File Download" — that's the 96.89 GB offline tar.

2. **Open the FHS shell first — AMD's tooling cannot run on NixOS directly.**
   `xsetup` and the `.bin`'s self-extractor are `#!/bin/bash` and shell out to
   `/bin/rm`, `/bin/mv`; NixOS has no `/bin/bash`, so a bare run dies with
   `bad interpreter: No such file or directory` after already unpacking ~1 GB
   into `/tmp/selfgz<pid>/` (the cleanup fails too — delete it). Everything
   below therefore runs inside `vivado-installer`, a `buildFHSEnv` shell that
   provides `/bin`, `/lib64` and the libs the installer's bundled JRE 21 needs:

   ```sh
   # allowUnfree is set for the *system* (modules/base/nix.nix) but not for the
   # flake's perSystem packages, so the CLI needs it passed in.
   NIXPKGS_ALLOW_UNFREE=1 nix run --impure .#packages.x86_64-linux.vivado-installer
   ```

   (drops you into a bash prompt inside that image; cwd and `$HOME` are your own;
   it exports `_JAVA_AWT_WM_NONREPARENTING=1`, the same Xwayland/Swing fix as the
   tool launcher — see "Using it". Unverified for `xsetup`'s own windows
   specifically, since re-running the installer means a 20 GB download.)

3. **Extract the installer** (inside that shell; never let the GUI wizard run —
   it installs the full default selection):

   ```sh
   chmod +x ~/Downloads/FPGAs_AdaptiveSoCs_Unified_SDI_*_Lin64.bin
   ~/Downloads/FPGAs_AdaptiveSoCs_Unified_SDI_*_Lin64.bin --noexec --target ~/xilinx-installer
   ```

   If a previous bare run left `/tmp/selfgz*/` behind, that directory is a
   complete extraction — `mv /tmp/selfgz* ~/xilinx-installer` instead of
   extracting again. Skip the `installLibs.sh` that comes out with the
   extraction — it is AMD's dependency bootstrapper for apt/dnf distros; the FHS
   image above is the NixOS equivalent.

4. **Use our trimmed install config** — this is the ≈20 GB knob
   (`install-configs/arty-z7-20.txt`, everything off except Vivado ML Standard
   + Zynq-7000; edit `Destination=` if you want a different path, then set
   `VIVADO_INSTALL_DIR` to match):

   ```sh
   mkdir -p ~/.Xilinx
   cp modules/features/vivado/install-configs/arty-z7-20.txt ~/.Xilinx/install_config.txt
   ```

   Checked against this installer's own vocabulary: `./xsetup -b ConfigGen`
   asks Product → `2. Vivado`, Edition → `1. Vivado ML Standard` and writes
   exactly the same 26 `Modules=` tokens in the same order (its defaults leave
   `DocNav` and `Vitis Model Composer` **on**, which is most of the size). If a
   future release renames an edition or token, regenerate that way and re-trim
   `Modules=` by hand.

5. **Batch install** — the web installer needs an auth token before it will
   download anything (`xsetup -h`: *"AuthTokenGen is used to generate an
   authentication token that will be used by the batch mode webinstaller to
   download install content"*). It asks for the AMD account in the terminal:

   ```sh
   cd ~/xilinx-installer
   ./xsetup -b AuthTokenGen
   ./xsetup -a XilinxEULA,3rdPartyEULA -b Install -c ~/.Xilinx/install_config.txt
   ```

   `WebTalkTerms` is **not** a valid value for `-a` in 2025.2 — the help lists
   only `[XilinxEULA,3rdPartyEULA]`, and passing a third name makes the whole
   `--agree` rejected: the installer prints "You have to accept the EULA to
   proceed" plus the usage block and exits. Older write-ups include it; drop it.

   Only the selected components are downloaded (≈20 GB) and installed to
   `Destination=`. Command form per AMD UG973, "Batch Mode Installation Using
   Web Installer". Delete `~/xilinx-installer` and the `.bin` when it finishes.

   On success the log ends with *"Tool installation completed. To run the tool
   successfully, please run the script `installLibs.sh` … requires the root
   privilege"*. Skip that sentence on NixOS — it is AMD's apt/dnf dependency
   bootstrapper; our FHS images provide the same libraries (verified:
   `vivado -version` runs inside the wrapper with no system-side install).

   Batch mode also pops a Swing window (the `xic` install client) which is
   unusable under Xwayland — no decorations, no resize, content clipped. It is
   purely cosmetic here: the download/install runs in the terminal and the
   install completed fine after the window was closed. If the JVM lingers
   afterwards (~230 MB), `pkill -f com.xilinx.xic.XIC`; `xsetup` starts it again
   on demand.

6. **Vendor the JTAG udev rules** into the repo (FTDI cable for the Arty Z7;
   without them Hardware Manager only opens the cable as root). They ship
   somewhere under `data/xicom/cable_drivers/lin64/install_script/install_drivers/`
   in the installed tree, so search for them instead of hardcoding the layout:

   ```sh
   find ~/Xilinx -path '*xicom/cable_drivers/lin64/install_script/install_drivers/*.rules' \
     -exec install -m 644 -t modules/features/vivado/udev-rules/ {} +
   git add -N modules/features/vivado/udev-rules/*.rules   # Nix only sees indexed files
   ```

   On 2025.2 they live in `<install>/<version>/data/xicom/...` (not under
   `Vivado/`), which is why this searches instead of hardcoding. Done for this
   install: `52-xilinx-digilent-usb.rules`, `52-xilinx-ftdi-usb.rules`,
   `52-xilinx-pcusb.rules` are vendored, and
   `nix build .#…vivado-udev-rules` installs all three into `/etc/udev/rules.d`
   (the directory's `README.md` is ignored by the `*.rules` glob). Re-do this
   after a toolchain bump.

7. **Make it a system package** — add the import to
   `modules/hosts/Amal/configuration.nix` next to the other features:

   ```nix
   self.nixosModules.vivado
   ```

   then `sudo nixos-rebuild switch --flake /home/atb/.config/nixos#amal`.
   The build **fails on purpose** until step 6 is done (no silent root-only JTAG).

## Using it

- `vivado` from `PATH` once the module is imported. Straight from the flake it
  needs the unfree flag:
  `NIXPKGS_ALLOW_UNFREE=1 nix run --impure .#packages.x86_64-linux.vivado`
  (`modules/base/nix.nix` allows unfree for the *system*, not for the flake's
  `perSystem` packages).
- The launcher resolves the install at runtime: `$VIVADO_INSTALL_DIR` →
  `$HOME/Xilinx` → `/opt/Xilinx`, newest `<install>/<version>/Vivado/` — which is
  the layout the web installer writes (`~/Xilinx/2025.2/Vivado/`).
- Verified end to end with the 2025.2 install in place:
  `NIXPKGS_ALLOW_UNFREE=1 nix run --impure .#packages.x86_64-linux.vivado -- -version`
  prints `vivado v2025.2 (64-bit)` / `SW Build 6299465`.
- Other binaries from the same tree: `VIVADO_BIN=hw_server nix run --impure
  .#packages.x86_64-linux.vivado` (the same `bin/` holds `bootgen`, `cs_server`,
  `hw_server`, …). `Vitis` sits next to it at `<install>/<version>/Vitis/`.
- Licensing: ML Standard / WebPACK covers Zynq-7000; Vivado's own license
  manager handles it on first run. `get_parts xc7z020*` resolves
  `xc7z020clg400-1` (the Arty Z7-20 part) out of the box.

- **Blank white Vivado window under niri/Xwayland is fixed in the launcher.**
  Java AWT probes the X server for a reparenting WM; under Xwayland it half-finds
  one and maps an undecorated frame it never paints. The launcher exports
  `_JAVA_AWT_WM_NONREPARENTING=1` (override or unset it yourself if you want).
  Measured on this session, same window grab (`xwd` of the 943x1005 frame):
  without the flag **1 unique color** (`mean=65535`, i.e. pure white — what you
  saw), with it **9289 colors** and a painted UI. Under Xvfb (no WM at all) it
  renders fine, which is how the WM-detection theory was pinned down. dwl's FAQ
  names Vivado for this exact variable.

## Board files — the Arty Z7-20 is not in AMD's install

AMD's tree ships 106 boards, none of them Digilent
(`get_boards *arty*` → empty). Official ones come from
<https://github.com/Digilent/vivado-boards>; point Vivado at them once and it
sticks (`~/.Xilinx/Vivado/Vivado_init.tcl` is sourced at startup):

```sh
git clone --depth 1 https://github.com/Digilent/vivado-boards ~/.local/share/vivado-boards
mkdir -p ~/.Xilinx/Vivado
echo 'set_param board.repoPaths [list /home/atb/.local/share/vivado-boards/new/board_files]' \
  > ~/.Xilinx/Vivado/Vivado_init.tcl
```

Verified afterwards, headless: `get_boards *arty*` lists
`digilentinc.com:arty-z7-20:1.1` (plus the a7/s7/z7-10 variants). Both commands
above have been run on amal, so this section is a re-install note, not a TODO.
The Tcl console shows the sourced file as `~/.Xilinx/Vivado_init.tcl` — it really
reads `~/.Xilinx/Vivado/Vivado_init.tcl`, ignore the missing segment. Vivado also
persisted the param into `~/.Xilinx/Vivado/2025.2/new_lnf.ini`, so the file only
matters again after a fresh state dir.

## Removal — get rid of Vivado completely

1. Remove the `self.nixosModules.vivado` import from the host's
   `configuration.nix` and rebuild (`nixos-rebuild switch --flake .#amal`).
2. Delete the toolchain and leftovers (`rm -rf` is enough; AMD's own uninstaller
   is `cd ~/Xilinx/.xinstall/<product>_<version> && ./xsetup -b Uninstall`, which
   `xsetup -h` says removes *all* products in that directory):

   ```sh
   rm -rf ~/Xilinx           # the installed tree (~25-30 GB) — or $VIVADO_INSTALL_DIR
   rm -rf ~/.Xilinx          # installer config, auth token, logs, license state
   rm -rf ~/xilinx-installer # if not already deleted after install
   rm -rf /tmp/selfgz*       # if a bare .bin run left its extraction behind
   rm ~/Downloads/FPGAs_AdaptiveSoCs_Unified_SDI_*_Lin64.bin
   ```
3. Delete this whole directory (`modules/features/vivado/`, vendored udev
   rules included) — `git rm -r modules/features/vivado`.
4. The `xilinx-nix-utils` flake input was already removed from `flake.nix`; a
   stale entry may linger in `flake.lock` — harmless, pruned by the next
   `nix flake update`.
5. Reclaim the wrapper closure: `nix-collect-garbage -d` after the rebuild in
   step 1 dropped it from the generation.

Nothing else touches the system: no state dirs, no firewall ports, no system
files beyond the udev rules, which disappear with the rebuild.

## References

- AMD UG973 — [Web Installer Download and Install](https://docs.amd.com/r/en-US/ug973-vivado-release-notes-install-license/Web-Installer-Download-and-Install),
  [Batch Mode Installation Using Web Installer](https://docs.amd.com/r/en-US/ug973-vivado-release-notes-install-license/Batch-Mode-Installation-Using-Web-Installer)
- Wrapper deps mirror [DLR-FT/xilinx-nix-utils](https://github.com/DLR-FT/xilinx-nix-utils) `wrap.nix`
  (rev `8ad07a1`, minus the now-broken gtk2).
- Friend's imperative flake (same idea, different wrapper): [MIT-OpenCompute/xilinx-flake](https://github.com/MIT-OpenCompute/xilinx-flake).
- The old hermetic approach (96.89 GB SFD requirement) lives in this file's git history.
