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
      ];

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
