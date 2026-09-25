{
  inputs,
  ...
}:
{
  perSystem =
    {
      pkgs,
      ...
    }:
    {
      packages.neovim = inputs.wrapper-modules.wrappers.neovim.wrap {
        inherit pkgs;

        runtimePkgs = with pkgs; [
          wl-clipboard
          ffmpeg-full
          lua-language-server
          clang-tools
          pyright
          jdt-language-server
          jdk21
        ];

        specs = {
          general = with pkgs.vimPlugins; [
            lz-n
            plenary-nvim
            nvim-lspconfig
            nvim-treesitter

            #completion
            nvim-web-devicons
            lspkind-nvim
            colorful-menu-nvim
            blink-cmp

            #misc
            snacks-nvim
            oil-nvim
            lualine-nvim
            luasnip
            telescope-nvim
          ];

          lazy = {
            lazy = true;
            data =
              (with pkgs.vimPlugins; [
                lazydev-nvim
                gitsigns-nvim
                nvim-autopairs
                fastaction-nvim
                mini-files
                codecompanion-nvim
              ])
              ++ (with pkgs; [
                nixd
                alejandra
              ]);
          };

          config =
            #lua
            ''
              vim.lsp.enable("lua_ls")
              vim.lsp.config("nixd", {
                       cmd = { "nixd" },
                       settings = {
                         nixd = {
                           nixpkgs = {
                             expr = "import <nixpkgs> { }",
                           },
                           formatting = {
                             command = { "alejandra" },
                           },
                         },
                       },
                     })
                     vim.lsp.enable("nixd")
              vim.lsp.config("clangd", { cmd = { "clangd" } })
              vim.lsp.enable("clangd")
              vim.lsp.config("pyright", {
              cmd = { "pyright-langserver", "--stdio" },
              filetypes = { "python" },
              settings = {
                python = {
                  analysis = {
                    typeCheckingMode = "basic",
                    autoSearchPaths = true,
                    useLibraryCodeForTypes = true,
                  },
                },
              },
            })
            vim.lsp.enable("pyright")
            vim.lsp.config("jdtls", {
              cmd = { "jdtls" },
              -- optional, but useful for multi-module projects
              root_markers = { ".git", "pom.xml", "build.gradle", "settings.gradle", "mvnw", "gradlew" },
              settings = {
                java = {
                  -- add your own preferences here, for example:
                  signatureHelp = { enabled = true },
                  completion = {
                    favoriteStaticMembers = {
                      "org.junit.Assert.*",
                      "org.junit.jupiter.api.Assertions.*",
                    },
                  },
                  sources = {
                    organizeImports = {
                      starThreshold = 9999,
                      staticStarThreshold = 9999,
                    },
                  },
                },
              },
            })
            vim.lsp.enable("jdtls")
            '';

          init = {
            data = null;
            before = [ "MAIN_INIT" ];
            config = "require('init')";
          };
        };

        settings.config_directory = ./.;
      };
    };
}
