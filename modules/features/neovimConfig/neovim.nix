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
                             command = { "nixpkgs-fmt" },
                           },
                         },
                       },
                     })
                     vim.lsp.enable("nixd")
              vim.lsp.config("clangd", { cmd = { "clangd" } })
              vim.lsp.enable("clangd")
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
