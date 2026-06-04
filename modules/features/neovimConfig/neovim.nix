{
  self,
  inputs,
  ...
}: {
  perSystem = {
    config,
    lib,
    pkgs,
    ...
  }: {
    packages.neovim = inputs.wrapper-modules.wrappers.neovim.wrap {
      inherit pkgs;

      runtimePkgs = with pkgs; [
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

          #misc
          snacks-nvim
          oil-nvim
          lualine-nvim
          telescope-nvim
        ];

        lazy = {
          lazy = true;
          data =
            (with pkgs.vimPlugins; [

            ])
            ++ (with pkgs; [
              nixd
              alejandra
            ]);
        };

        init = {
          data = null;
          before = ["MAIN_INIT"];
          config = "require('init')";
        };
      };

      settings.config_directory = .;
    };
  };
}
