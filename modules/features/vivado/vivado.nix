{self, ...}: let
  # Imperative toolchain, declarative wrapper: the ~150 GB full edition is avoided at
  # the DOWNLOAD level by using AMD's web installer, which fetches only the components
  # selected in install-configs/arty-z7-20.txt (Vivado ML Standard + Zynq-7000,
  # ≈20 GB download, 52 GB installed). Nix never fetches anything from AMD
  # (impossible anyway: EULA click-through); it provides the FHS wrappers and the
  # udev rules below.
  # Setup AND removal steps: README.md in this directory.
  #
  # Why not the old hermetic module: AMD's offline single-file download is 96.89 GB
  # (see git history of this file / the xilinx-nix-utils flake). 20 GB download was
  # the chosen tradeoff; the install stays outside the nix store by design.
  # Runs inside buildFHSEnv's /init (`exec <runScript> "$@"`). Resolves the
  # imperative install at runtime so the wrapper itself is store-pure:
  # $VIVADO_INSTALL_DIR, else $HOME/Xilinx, else /opt/Xilinx. The web installer
  # lays out <install>/<version>/Vivado/ (measured on 2025.2 -- NOT
  # <install>/Vivado/<version>), newest version dir wins.
  # $VIVADO_BIN picks another binary from that product's bin/ (hw_server, ...).
  launcher = pkgs:
    pkgs.writeShellScript "vivado-launcher" ''
      set -eu
      find_vivado() {
        find "$1" -mindepth 2 -maxdepth 2 -type d -name Vivado 2>/dev/null | sort -V | tail -n1
      }
      install="''${VIVADO_INSTALL_DIR:-}"
      if [ -n "$install" ]; then
        vdir=$(find_vivado "$install")
      else
        for c in "$HOME/Xilinx" /opt/Xilinx; do
          if [ -d "$c" ]; then
            vdir=$(find_vivado "$c")
            [ -n "$vdir" ] && install="$c" && break
          fi
        done
      fi
      if [ -z "''${vdir:-}" ]; then
        echo "vivado: no <install>/<version>/Vivado found under \$HOME/Xilinx or /opt/Xilinx." >&2
        echo "        Follow modules/features/vivado/README.md, or set VIVADO_INSTALL_DIR." >&2
        exit 1
      fi
      bin="$vdir/bin/''${VIVADO_BIN:-vivado}"
      if [ ! -x "$bin" ]; then
        echo "vivado: $bin is missing -- incomplete install or wrong VIVADO_BIN?" >&2
        exit 1
      fi
      export LC_NUMERIC=en_US.UTF-8
      # Vivado's GUI is Java AWT/Swing, which probes the X server for a
      # *reparenting* window manager and, when it half-believes one exists
      # (Xwayland, and tiling WMs generally), maps an undecorated frame it never
      # paints -- you get a blank white window forever. Declaring the WM
      # non-reparenting is the standard fix and dwl's FAQ names Vivado
      # specifically; Xvfb (no WM at all) renders fine, which is how this was
      # pinned down. Overridable: set it yourself to change or unset the default.
      export _JAVA_AWT_WM_NONREPARENTING="''${_JAVA_AWT_WM_NONREPARENTING:-1}"
      set +u; . "$vdir/settings64.sh"; set -u
      exec "$bin" "$@"
    '';

  # Mirrors DLR-FT/xilinx-nix-utils' wrap.nix (rev 8ad07a1, proven against the
  # 2025.2 toolchain) minus gtk2: the trimmed config installs Vivado only (Swing
  # GUI), which never needs it, and this nixpkgs marks gtk+-2.24.33 broken.
  # Do NOT let the bare pkgs.vivado or a second wrapper coexist with this one.
  vivadoFhs = pkgs:
    pkgs.buildFHSEnv {
      pname = "vivado";
      # Cosmetic only -- the launcher globs whatever version dir the installer wrote.
      version = "2025.2.1";
      runScript = launcher pkgs;
      targetPkgs = p:
        with p; [
          coreutils
          graphviz
          hostname
          pkg-config
          python3
          unzip
          which
          stdenv.cc.cc.lib
          libpng
          libusb1
          libuuid
          libxcrypt
          libyaml
          lsb-release
          pixman
          zlib
          (libtinfo.override {ncurses = ncurses5;})
          (libtinfo.override {ncurses = ncurses6;})
          fontconfig
          freetype
          glib
          gtk3
          libx11
          libxext
          libxft
          libxi
          libxrender
          libxtst
          libxcb
          xlsclients
          xorg-server
          # Vivado spawns its "Custom Editor..." from *inside* this container through
          # Runtime.exec(String) (planAhead.jar, ui.utils.I): the string is tokenised
          # on whitespace with no shell, and the first token resolves against the
          # container PATH -- /run/wrappers/bin:/usr/bin:/usr/sbin plus this list, and
          # it inherits the host PATH tail, so /run/current-system/sw/bin and
          # ~/.nix-profile/bin resolve here as well (which is how Vivado's stock Kate
          # entry gets as far as an exec). When the first token cannot be resolved the
          # exec throws: Vivado pops "Unable to launch external text editor" and
          # additionally drops CODE_EDITOR from its in-memory properties, so every
          # later open in that same session falls back to the internal editor with no
          # message at all.
          # neovim is the flake's configured wrapper (never bare pkgs.neovim: that
          # would be a second, unconfigured copy). kitty stays the bare package on
          # purpose: the configured kitty wrapper appends its default shell AFTER
          # "$@" (`exec kitty --config … "$@" …/fish`), so a program passed to it
          # gets a stray trailing `fish` argument -- nvim would open a buffer named
          # "fish". Bare kitty still reads ~/.config/kitty/kitty.conf. kitty.terminfo
          # because kitty exports TERM=xterm-kitty and nvim needs that entry.
          kitty
          kitty.terminfo
          self.packages."${pkgs.stdenv.hostPlatform.system}".neovim
          # Editor shim: point the Custom Editor field at /usr/bin/vivado-editor.
          # It logs what Vivado actually passed (argv, cwd, display env) to
          # ~/vivado-editor.log -- $HOME, not /tmp, because /tmp is a fresh tmpfs
          # inside the container (only /tmp/.X11-unix is re-bound).
          # The unsets are the real fix: Vivado poisons everything it spawns.
          # PYTHONHOME/PYTHONPATH point at its bundled interpreter
          # (tps/lnx64/python-3.13.0) and kitty embeds CPython, so kitty died during
          # interpreter startup -- "Fatal Python error: Failed to import encodings
          # module" -- before creating a window. Vivado needs those variables itself,
          # so they are dropped only for the editor child; the same applies to any
          # Python tool Vivado spawns, including nvim's python provider.
          # The probe-and-fallback handles the second failure seen once Python was
          # fixed: kitty's Wayland path dies with "glfw error 65542: EGL: Failed to
          # initialize EGL ... display_present: 0 egl_platform_present: 1" when
          # spawned by Vivado, even though the identical command works from a shell
          # in the same container. A throwaway window tests the Wayland path; on
          # failure the editor is retried over X11/GLX (which is what Vivado's own
          # GUI uses, via XWayland).
          (pkgs.writeShellScriptBin "vivado-editor" ''
            LOG="$HOME/vivado-editor.log"
            {
              echo "=== $(date -Is)"
              echo "cwd: $(pwd)"
              i=1
              for a in "$@"; do echo "arg$i: [$a]"; i=$((i + 1)); done
              echo "kitty: $(command -v kitty) | nvim: $(command -v nvim)"
              echo "-- display/GL/python env:"
              env | grep -E '^(DISPLAY|WAYLAND|XDG|XAUTH|EGL|GL|GLFW|LIBGL|MESA|QT_|PYTHON|LD_LIBRARY)' | sed 's/^/  /'
            } >> "$LOG" 2>&1
            unset PYTHONHOME PYTHONPATH PYTHONSTARTUP LD_LIBRARY_PATH
            if timeout 10 kitty --title vivado-editor-probe true >> "$LOG" 2>&1; then
              exec kitty nvim "$@" >> "$LOG" 2>&1
            else
              echo "[shim] Wayland probe failed -> retrying over X11" >> "$LOG"
              exec env -u WAYLAND_DISPLAY kitty nvim "$@" >> "$LOG" 2>&1
            fi
          '')
        ];
      meta = {
        description = "FHS wrapper around the imperatively installed AMD Vivado (web-installer edition)";
        license = pkgs.lib.licenses.unfree;
      };
    };

  # AMD's installer needs an FHS image as much as the tool does: `xsetup` and the
  # .bin's self-extractor are `#!/bin/bash` and shell out to `/bin/rm`, so a bare
  # run on NixOS dies with "bad interpreter: No such file or directory" (after
  # unpacking ~1 GB into /tmp/selfgz*/, which its own /bin/rm cleanup then fails
  # to remove). This is the installer's own, smaller set -- bash plus the libs
  # its bundled JRE 21 dlopen's, from AMD UG973's prerequisites list -- and an
  # interactive shell instead of the launcher (README step 2). Verified with this
  # package: it builds, /bin/bash and /bin/rm exist inside, the .bin extracts via
  # --noexec --target and `./xsetup --help` runs. `-b ConfigGen` and
  # `-b AuthTokenGen` were verified in the equivalent scratch image this list was
  # taken from.
  vivadoInstallerFhs = pkgs:
    pkgs.buildFHSEnv {
      pname = "vivado-installer";
      version = "2025.2.1";
      runScript = pkgs.writeShellScript "vivado-installer-shell" ''
        # xsetup's own Swing windows hit the same Java AWT WM-detection bug under
        # Xwayland (the blank, clipped window during the install). Same default as
        # the tool launcher; see the launcher comment.
        export _JAVA_AWT_WM_NONREPARENTING="''${_JAVA_AWT_WM_NONREPARENTING:-1}"
        exec bash "$@"
      '';
      targetPkgs = p:
        with p; [
          bash
          binutils
          bzip2
          cpio
          coreutils
          diffutils
          findutils
          gawk
          stdenv.cc.cc.lib
          glibc
          libxcrypt
          linux-pam
          ncurses5
          numactl
          openssl
          gnused
          systemd
          util-linux
          vte
          which
          xz
          zlib
          fontconfig
          freetype
          glib
          gtk3
          libx11
          libxext
          libxft
          libxi
          libxrender
          libxtst
          libxcb
        ];
      meta = {
        description = "glibc/FHS shell for running AMD's Vivado web installer on NixOS";
        license = pkgs.lib.licenses.unfree;
      };
    };
in {
  # Imported by amal (README step 7) since the 2025.2 web-installer run is done
  # and the rules below are vendored. Removal: README.md, "Removal".
  flake.nixosModules.vivado = {pkgs, ...}: {
    # Built with the *host's* pkgs on purpose: modules/base/nix.nix sets
    # nixpkgs.config.allowUnfree for the NixOS configs, but the flake's perSystem
    # instance (self.packages) does not, so referencing it here fails the
    # toplevel eval with an unfree refusal. The perSystem target below stays for
    # `nix run`/measuring.
    environment.systemPackages = [(vivadoFhs pkgs)];

    # The Arty Z7-20 speaks JTAG over an FTDI cable; without the vendor rules
    # Hardware Manager can only open it as root. The rules ship inside the
    # install; vendor a copy into ./udev-rules/ (README step 6) so this module
    # evaluates without the toolchain present. Fails the build instead of
    # silently shipping an empty rules dir.
    services.udev.packages = [
      (
        pkgs.runCommand "vivado-udev-rules"
        {}
        ''
          mkdir -p $out/etc/udev/rules.d
          rules=$(find ${./udev-rules} -maxdepth 1 -name '*.rules')
          if [ -z "$rules" ]; then
            echo "vivado: modules/features/vivado/udev-rules/ has no *.rules yet."
            echo "        Copy them out of the installed tree (README.md step 6), git add -N them, rebuild."
            exit 1
          fi
          for f in $rules; do cp --no-preserve=mode "$f" $out/etc/udev/rules.d/; done
        ''
      )
    ];
  };

  # Standalone wrapper target, buildable before any install exists (the launcher
  # only resolves at runtime). Guarded: flake.systems carries aarch64/darwin too.
  perSystem = {
    pkgs,
    system,
    ...
  }: {
    packages =
      if system == "x86_64-linux"
      then {
        vivado = vivadoFhs pkgs;
        # README step 2: the shell AMD's installer has to be run inside.
        vivado-installer = vivadoInstallerFhs pkgs;
      }
      else {};
  };
}
