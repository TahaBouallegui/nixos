{ self, ... }:
{
  flake.nixosModules.ai =
    { pkgs, ... }:
    {
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
        self.packages.${pkgs.stdenv.hostPlatform.system}.bat
        pkgs.nix-tree
        pkgs.nodejs
        pkgs.python3
        pkgs.deepseek-harness
        # pkgs.deepseek-harness does not declare a runtime dependency on
        # bubblewrap, and the Nix build of its sandbox platform package omits
        # bin/landlock-run, so the harness sandbox would have no usable Linux
        # runner (SANDBOX_UNAVAILABLE on every confined tool call).
        pkgs.bubblewrap

        # Provider CLIs for REA (rea-agents, mounted by the dsh-plugin-rea bundle).
        # REA never installs tools for itself: each of these is caller-supplied and
        # discovered on PATH, optionally overridable with REA_<TOOL>_COMMAND. All of
        # them have substitutes on cache.nixos.org, so the switch only downloads.
        pkgs.ghidra      # deep native analysis + decompilation (ghidra-run 2026-07-02)
        pkgs.binutils    # objdump / readelf / nm / strings  (REA_OBJDUMP_COMMAND)
        pkgs.gdb         # GDB/MI debugger sessions          (REA_GDB_COMMAND)
        pkgs.rizin       # Rizin debugger sessions           (REA_RIZIN_COMMAND)
        pkgs.radare2     # not an REA provider - general RE convenience
        pkgs.wabt        # wasm validation + WAT             (REA_WABT_BIN_DIRECTORY);
                         # nixpkgs has 1.0.41, REA pins 1.0.42, so it may stay unavailable
        pkgs.tshark      # tshark + capinfos 4.6.9           (REA_TSHARK_COMMAND / REA_CAPINFOS_COMMAND)
        pkgs.apktool     # Android resource decoding         (REA_APKTOOL_COMMAND)
        pkgs.jadx        # Android Java decompiler 1.5.6; REA's JADX lane additionally
                         # wants a JADX MCP jar through REA_JADX_MCP_JAR
        pkgs.jdk         # java for that JADX MCP jar (already in the store: ~free)
        pkgs.mitmproxy   # mitmdump 12.2.3 - exact match for REA's pinned version
        pkgs.unblob      # firmware extraction 26.6.4        (REA_UNBLOB_COMMAND)
        pkgs.binwalk     # firmware signature scan 3.1.0     (verified against REA's 3.1.0)
        pkgs.sigrok-cli  # logic-analyzer dumps 0.8.0        (REA_SIGROK_COMMAND);
                         # REA was verified against 0.7.2, so decoder help may misparse
        pkgs.frida-tools # frida CLI instrumentation (attach / spawn sessions)
      ];

      # REA's pwntools lanes (ELF layout, recorded-crash cores) demand an absolute
      # interpreter with pwntools installed. nixpkgs gives pwntools 4.15.0 (the exact
      # pin) but pairs it with pyelftools 0.32 / unicorn 2.1.4 instead of REA's 0.33 /
      # 2.1.2, so those two tools can still report unavailable until REA accepts them.
      # Read from /etc/environment, so a re-login is needed for it to reach the harness.
      environment.variables.REA_PWNTOOLS_PYTHON =
        "${pkgs.python3.withPackages (ps: [ ps.pwntools ])}/bin/python3";

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
