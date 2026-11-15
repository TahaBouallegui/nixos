{inputs, ...}: {
  perSystem = {pkgs, ...}: {
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
        vhdl-ls
      ];

      specs = {
        general = with pkgs.vimPlugins; [
          lz-n
          plenary-nvim
          nvim-lspconfig
          (nvim-treesitter.withPlugins (
            p:
              with p; [
                nix
                bash
                fish
                python
                java
                toml
                yaml
                json
                c
                lua
                vhdl
              ]
          ))

          #completion
          nvim-web-devicons
          lspkind-nvim
          colorful-menu-nvim
          blink-cmp

          #misc
          # nvzone/menu's UI library: menu.lua `require`s volt the moment a
          # menu opens, so it has to sit on the runtimepath already -- it has
          # no setup() call, so startup cost is one rtp entry.
          nvzone-volt
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
              which-key-nvim
              nvzone-menu
              hardtime-nvim
            ])
            ++ (with pkgs; [
              nixd
              alejandra
            ]);
        };

        lsp = {
          # A spec's value (or .data) is the *plugin*; its configuration code goes
          # in the spec's `config` field. Passing the lua directly as the spec value
          # stored it as spec info and never sourced it, so none of the
          # vim.lsp.enable() calls below ever ran -- verified: no LSP FileType
          # autocmds are registered at any point during startup, and
          # vim.lsp.config.nixd.settings stays nil. `data = null` (same shape as the
          # `init` spec below) is what makes it run.
          data = null;
          config =
            #lua
            ''
                vim.lsp.enable("lua_ls")

                -- nixd resolves `./.`  against its own cwd, which the LSP
                -- client sets to the root it auto-detects from `flake.nix` --
                -- no hardcoded path, works for any clone of this flake.
                local nixd_settings = {
                  nixpkgs = {
                    expr = 'import (builtins.getFlake (toString ./.)).inputs.nixpkgs { }',
                  },
                  formatting = {
                    command = { "alejandra" },
                  },
                }
                -- Per-host NixOS option completion needs to know which
                -- `nixosConfigurations.<name>` is "this machine" -- that's
                -- inherently host-specific, so each host opts in by setting
                -- $NIXD_HOST (see environment.sessionVariables) instead of
                -- hardcoding a hostname here.
                local nixd_host = os.getenv("NIXD_HOST")
                if nixd_host then
                  nixd_settings.options = {
                    nixos = {
                      expr = '(builtins.getFlake (toString ./.)).nixosConfigurations.' .. nixd_host .. '.options',
                    },
                  }
                end
                vim.lsp.config("nixd", {
                  cmd = { "nixd" },
                  settings = { nixd = nixd_settings },
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
              -- nvim-lspconfig ships the vhdl_ls default (cmd vhdl_ls, filetypes
              -- vhd/vhdl, root = vhdl_ls.toml, single-file support), so enabling
              -- it is enough -- the binary comes from pkgs.vhdl-ls above.
              vim.lsp.enable("vhdl_ls")
            '';
        };

        init = {
          data = null;
          before = ["MAIN_INIT"];
          config = "require('init')";
        };
      };

      settings.config_directory = ./.;
    };
  };
}
