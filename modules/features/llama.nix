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
        profiles.tui.bundles = [ pkgs.dsh.bundles.tui ];
        defaultProfile = "nix-tui";
      };

      environment.systemPackages = [
        (pkgs.llama-cpp-cuda.overrideAttrs (old: {
          cmakeFlags = (old.cmakeFlags or [ ]) ++ [
            "-DCMAKE_CUDA_ARCHITECTURES=61"
          ];
        }))
      ];

      services.llama-cpp = {
        package = (
          pkgs.llama-cpp.overrideAttrs (old: {
            cmakeFlags = (old.cmakeFlags or [ ]) ++ [
              "-DGGML_NATIVE=ON"
              "-DGGML_LTO=ON"
              "-DGGML_OPENMP=ON"
            ];
          })
        );
        enable = false;
        settings = {
          hf-repo = "HauhauCS/Qwen3.6-35B-A3B-Uncensored-HauhauCS-Aggressive:Q4_K_M";
          threads = 5;
          flash-attn = "on";
          jinja = "";
          tools = "all";
          ctx-size = 131072;
        };
      };
    };
}
