# What goes here

The FTDI/JTAG udev rules for the Arty Z7-20 cable, vendored from the installed
toolchain so `self.nixosModules.vivado` can evaluate without Vivado installed.
`vivado.nix` **fails the build** if this directory contains no `*.rules` file —
that's deliberate: an empty rules dir silently means "Hardware Manager works as
root only".

Copy once after the install (README step 5):

```sh
install -m 644 ~/Xilinx/data/xicom/cable_drivers/lin64/install_script/install_drivers/*.rules \
  modules/features/vivado/udev-rules/
git add -N modules/features/vivado/udev-rules/*.rules   # Nix only sees indexed files
```

Removal: delete the `*.rules` files with the rest of the feature dir (README, "Removal").
