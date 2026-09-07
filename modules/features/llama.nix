{ self, inputs, ... }:
{
  flake.nixosModules.ai =
    { pkgs, lib, ... }:
    {
      imports = [
        inputs.deepseek-harness.nixosModules.default
      ];

      nix.settings = {
        substituters = [ "https://deepseek-harness-nix.cachix.org" ];
        trusted-public-keys = [
          "deepseek-harness-nix.cachix.org-1:5NrkwLN9veNMhiINtU5ZeV4isXFhFsOwn6Ms7J1M+TA="
        ];
      };

      programs.dsh = {
        enable = true;
        profiles.tui.bundles = [
          pkgs.dsh.bundles.tui
          pkgs.dsh.bundles.modsearch
          pkgs.dsh.bundles.web-app
          pkgs.dsh.bundles.web-ui
        ];
        defaultProfile = "nix-tui";
      };

      environment.systemPackages = [
        (inputs.ik-llama.packages.${pkgs.system}.default.overrideAttrs (old: {
          cmakeFlags = old.cmakeFlags ++ [
            "-DGGML_CPU_ALL_VARIANTS=ON"
            "-DGGML_BACKEND_DL=ON"
          ];
        }))
        pkgs.pi-coding-agent
      ];

      services.llama-cpp = {
        package = (inputs.ik-llama.packages.${pkgs.system}.default).overrideAttrs (old: {
          cmakeFlags = old.cmakeFlags ++ [
            "-DGGML_CPU_ALL_VARIANTS=ON"
            "-DGGML_BACKEND_DL=ON"
          ];
        });
        enable = true;
        settings = {
          hf-repo = "0xKitkat/Ornith-1.5-35B-A3B-Uncensored-GGUF";
          hf-file = "Ornith-1.5-35B-Uncensored-Q4_K_M.gguf";
          jinja = "";
          threads = 2;
          ctx-size = 131072;
          reasoning-format = "deepseek";
          port = 8900;
          temp = 0.6;
          top_p = 0.95;
          top_k = 20;
          batch-size = 4096;
          ubatch-size = 512;
          webui = "none";
        };
      };
    };
}
