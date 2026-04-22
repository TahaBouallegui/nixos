{ self, inputs, ... } : 

{
  perSystem = { config, lib, pkgs, ... }: {
    packages.neovim = inputs.wrapper-modules.wrappers.neovim.wrap {
      inherit pkgs;
      
    extraPackages = with pkgs; [
	  wl-clipboard
	  ffmpeg-full
	  lua-language-server
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

	];

	lazy = {
	  lazy = true;
	  data = (with pkgs.vimPlugins; [
	    lazydev-nvim
	    gitsigns-nvim
	    nvim-autopairs
	    fastaction-nvim
	    mini-files
	    codecompanion-nvim
	  ]) ++ (with pkgs; [
	    nixd
	    alejandra
	    typescript-language-server
	  ]);
	};

	config =
        #lua
        ''
	  vim.lsp.enable("lua_ls")
          vim.lsp.config("ts_ls", {
            settings = {
              suggestionActions = {
                enabled = false
              }
            }
          })
          vim.lsp.enable("ts_ls")


          vim.lsp.config("qmlls", {
            cmd = { "qmlls", "-E" },
          })
          vim.lsp.enable("qmlls")


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
        '';
        

	init = {
	  data = null;
	  before = [ "MAIN_INIT" ];
	  config = "require('init')";
	};
      };

      settings.config_directory = ./neovimConfig;
    };
  };
}
