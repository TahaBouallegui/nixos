{ self, inputs, ... }:
{
  flake.nixosModules.ai =
    { pkgs, lib, ... }:
    {
      imports = [
        inputs.deepseek-harness.nixosModules.default
      ];

      programs.dsh = {
        enable = true;

        profiles.web = {
          # Keep the default `managed` mode so Nix owns the profile directory.
          bundles = [
            pkgs.dsh.bundles.base
            pkgs.dsh.bundles.web-app
            pkgs.dsh.bundles.web-ui
          ];

          # The patch list mirrors the Web profile's cordis.patch.yml exactly.
          # Nix serialises this to YAML and writes it to
          #   ~/.dsh/profiles/nix-tui/cordis.patch.yml
          # on every activation, so the provider stays reproducible.
          patch = [
            {
              id = "ui-settings-general";
              name = "@deepseek-ai/dsh-client-ui-settings-general";
              config = {
                welcomeNoticeVersion = "2026-08-13.1";
              };
            }

            {
              id = "llm-pi-ai";
              name = "@deepseek-ai/dsh-llm-pi-ai";
              config = {
                providers = {
                  zabeth24 = {
                    displayName = "zabeth24";
                    apiKeyEnv = "ZABETH24_API_KEY";
                    api = "openai-completions";
                    baseURL = "http://zabeth24.tail5481a4.ts.net:8080/v1";
                    models = [
                      {
                        id = "peculiar-ragdoll/Tiel-Coder-35B-A3B-GGUF-MTP:UD-Q4_K_XL";
                        name = "peculiar-ragdoll/Tiel-Coder-35B-A3B-GGUF-MTP:UD-Q4_K_XL";
                      }
                    ];
                  };
                };
              };
            }
          ];
        };
      };

      environment.sessionVariables = {
        ZABETH24_API_KEY = "x";
      };

      environment.systemPackages = [
        #(inputs.ik-llama.packages.${pkgs.system}.default.overrideAttrs (old: {
        #  cmakeFlags = old.cmakeFlags ++ [
        #    "-DGGML_CPU_ALL_VARIANTS=ON"
        #    "-DGGML_BACKEND_DL=ON"
        #  ];
        #}))
        pkgs.mcp-nixos
      ];

      services.llama-cpp = {
        package =
          (inputs.ik-llama.packages.${pkgs.stdenv.hostPlatform.system}.default).overrideAttrs
            (old: {
              cmakeFlags = old.cmakeFlags ++ [
                "-DGGML_CPU_ALL_VARIANTS=ON"
                "-DGGML_BACKEND_DL=ON"
              ];
            });
        enable = false;
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
        };
      };
    };
}
