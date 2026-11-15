{self, ...}: {
  # Needs a host that also imports `self.nixosModules.pkgs-stable` (`desktop`
  # does): importing it here too made `_module.args.pkgs-stable` a duplicate
  # definition and `amal` stopped evaluating, so the dependency stays implicit.
  flake.nixosModules.ai = {
    pkgs,
    pkgs-stable,
    ...
  }: {
    environment.systemPackages = [
      pkgs.llama-cpp
      pkgs.chromium
      pkgs.jq
      pkgs.poppler-utils
      pkgs.librsvg
      pkgs.sqlite
      pkgs.pkg-config
      pkgs.gnumake
      pkgs.parallel
      pkgs.dnsutils
      pkgs.pciutils
      pkgs.lsof
      pkgs.nix-tree
      pkgs.nodejs
      pkgs.python3
      pkgs.deepseek-harness
      # pkgs.deepseek-harness does not declare a runtime dependency on
      # bubblewrap, and the nix build of its sandbox platform package omits
      # bin/landlock-run, so the harness sandbox would have no usable linux
      # runner (sandbox_unavailable on every confined tool call).
      pkgs.bubblewrap

      # Provider CLIs for REA (rea-agents, mounted by the dsh-plugin-rea bundle).
      # REA never installs tools for itself: each of these is caller-supplied and
      # discovered on PATH, optionally overridable with REA_<TOOL>_COMMAND. All of
      # them have substitutes on cache.nixos.org, so the switch only downloads.
      pkgs.ghidra # deep native analysis + decompilation (ghidra-run 2026-07-02)
      pkgs.binutils # objdump / readelf / nm / strings  (REA_OBJDUMP_COMMAND)
      pkgs.gdb # GDB/MI debugger sessions          (REA_GDB_COMMAND)
      pkgs.rizin # Rizin debugger sessions           (REA_RIZIN_COMMAND)
      pkgs.radare2 # not an REA provider - general RE convenience
      pkgs.wabt
      # wasm validation + WAT             (REA_WABT_BIN_DIRECTORY);
      # nixpkgs has 1.0.41, REA pins 1.0.42, so it may stay unavailable
      pkgs.tshark # tshark + capinfos 4.6.9           (REA_TSHARK_COMMAND / REA_CAPINFOS_COMMAND)
      pkgs.apktool # Android resource decoding         (REA_APKTOOL_COMMAND)
      pkgs.jadx
      # Android Java decompiler 1.5.6; REA's JADX lane additionally
      # wants a JADX MCP jar through REA_JADX_MCP_JAR
      pkgs.jdk # java for that JADX MCP jar (already in the store: ~free)
      # mitmdump 12.2.3 - exact match for REA's pinned version, and deliberately
      # from nixpkgs-stable: unstable's 12.3.0 dies in checkPhase against openssl
      # 3.5.9 (its emSign root-CA fixtures now raise `SSL:
      # CERTIFICATE_VERIFY_FAILED: certificate rejected`), so that drv cannot be
      # built at all. Stable's is a substitute, not a compile: verified 200 on
      # cache.nixos.org for
      # ka6adl2i3wpkpmqigqkml5mbsi77nscv-python3.13-mitmproxy-12.2.3.
      pkgs-stable.mitmproxy
      pkgs.unblob # firmware extraction 26.6.4        (REA_UNBLOB_COMMAND)
      pkgs.binwalk # firmware signature scan 3.1.0     (verified against REA's 3.1.0)
      pkgs.sigrok-cli
      # logic-analyzer dumps 0.8.0        (REA_SIGROK_COMMAND);
      # REA was verified against 0.7.2, so decoder help may misparse
      pkgs.frida-tools # frida CLI instrumentation (attach / spawn sessions)

      # Image editors — the three the rich-ui README's demo entity list
      # recommends (Krita / Inkscape / GIMP). All have substitutes on
      # cache.nixos.org: 153 + 43 + 208 MiB download (419 + 231 + 650 unpacked),
      # so the switch only downloads. Inkscape and GIMP are scriptable headless
      # (`inkscape --export-type=…`, `gimp -i -b "(script-fu …)"`); Krita is
      # GUI-only. pkgs.gimp-with-plugins is the same closure +9 MiB if the
      # extra plugins are ever wanted.
      pkgs.krita # 6.0.4.1 - painting + 2D animation
      pkgs.inkscape # 1.4.4 - SVG/vector editor, also a real CLI
      pkgs.gimp # 3.2.6 - raster retouching and compositing
    ];

    # REA's pwntools lanes (ELF layout, recorded-crash cores) demand an absolute
    # interpreter with pwntools installed. nixpkgs gives pwntools 4.15.0 (the exact
    # pin) but pairs it with pyelftools 0.32 / unicorn 2.1.4 instead of REA's 0.33 /
    # 2.1.2, so those two tools can still report unavailable until REA accepts them.
    # Read from /etc/environment, so a re-login is needed for it to reach the harness.
    environment.variables.REA_PWNTOOLS_PYTHON = "${
      pkgs.python3.withPackages (ps: [ps.pwntools])
    }/bin/python3";

    services.llama-cpp = {
      package = pkgs.llama-cpp;
      enable = false;
      settings = {
        hf-repo = "0xKitkat/Ornith-1.5-35B-A3B-Uncensored-GGUF:Q4_K_M";
        jinja = "";
        threads = 6;
        threads-batch = 8;
        ctx-size = 131072;
        reasoning-format = "deepseek";
        port = 8901;
        temp = 0.6;
        top_p = 0.95;
        top_k = 20;
        batch-size = 4096;
        ubatch-size = 512;
        flash-attn = "on";
      };
    };
  };
}
