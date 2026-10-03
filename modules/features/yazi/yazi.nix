{ self, inputs, ... }:
{
  flake.wrappersModules.yazi =
    { config, ... }:
    {
      plugins = with config.pkgs.yaziPlugins; {
        drag = drag;
        git = git;
        smart-enter = smart-enter;
        gvfs = gvfs;
        zoom = zoom;
      };

      flavors = {
        # Yazi expects a flavor to be a directory (named `<name>.yazi` once
        # linked) containing a `flavor.toml` -- not a flat file. There is no
        # generic base16-style palette table in yazi's schema either: every
        # section needs its own named fg/bg fields (verified against the real
        # shipped `nord.yazi` flavor, not the docs prose alone -- got bitten
        # twice assuming a schema that doesn't actually exist).
        "myTheme" = config.pkgs.writeTextDir "flavor.toml" ''
          [mgr]
          cwd = { fg = "${self.theme.base0D}" }

          hovered = { reversed = true }
          preview_hovered = { underline = true }

          find_keyword = { fg = "${self.theme.base0A}", bold = true, italic = true, underline = true }
          find_position = { fg = "${self.theme.base0E}", bg = "reset", bold = true, italic = true }

          marker_copied = { fg = "${self.theme.base0B}", bg = "${self.theme.base0B}" }
          marker_cut = { fg = "${self.theme.base08}", bg = "${self.theme.base08}" }
          marker_marked = { fg = "${self.theme.base0D}", bg = "${self.theme.base0D}" }
          marker_selected = { fg = "${self.theme.base0A}", bg = "${self.theme.base0A}" }

          tab_active = { reversed = true }
          tab_inactive = { fg = "${self.theme.base03}" }
          tab_width = 1

          count_copied = { fg = "${self.theme.base00}", bg = "${self.theme.base0B}" }
          count_cut = { fg = "${self.theme.base00}", bg = "${self.theme.base08}" }
          count_selected = { fg = "${self.theme.base00}", bg = "${self.theme.base0A}" }

          border_symbol = "│"
          border_style = { fg = "${self.theme.base02}" }

          [tabs]
          active = { fg = "${self.theme.base00}", bg = "${self.theme.base0D}", bold = true }
          inactive = { fg = "${self.theme.base0D}", bg = "${self.theme.base01}" }

          [mode]
          normal_main = { fg = "${self.theme.base00}", bg = "${self.theme.base0D}", bold = true }
          normal_alt = { fg = "${self.theme.base0D}", bg = "${self.theme.base01}" }
          select_main = { fg = "${self.theme.base00}", bg = "${self.theme.base0E}", bold = true }
          select_alt = { fg = "${self.theme.base0E}", bg = "${self.theme.base01}" }
          unset_main = { fg = "${self.theme.base00}", bg = "${self.theme.base09}", bold = true }
          unset_alt = { fg = "${self.theme.base09}", bg = "${self.theme.base01}" }

          [status]
          perm_sep = { fg = "${self.theme.base03}" }
          perm_type = { fg = "${self.theme.base0D}" }
          perm_read = { fg = "${self.theme.base0A}" }
          perm_write = { fg = "${self.theme.base08}" }
          perm_exec = { fg = "${self.theme.base0B}" }

          progress_label = { fg = "${self.theme.base07}", bold = true }
          progress_normal = { fg = "${self.theme.base0D}", bg = "${self.theme.base02}" }
          progress_error = { fg = "${self.theme.base08}", bg = "${self.theme.base02}" }

          [pick]
          border = { fg = "${self.theme.base0D}" }
          active = { fg = "${self.theme.base0E}", bold = true }
          inactive = { fg = "${self.theme.base05}" }

          [input]
          border = { fg = "${self.theme.base0D}" }
          title = { fg = "${self.theme.base05}" }
          value = { fg = "${self.theme.base07}" }
          selected = { reversed = true }

          [cmp]
          border = { fg = "${self.theme.base0D}" }

          [tasks]
          border = { fg = "${self.theme.base0D}" }
          title = { fg = "${self.theme.base07}" }
          hovered = { fg = "${self.theme.base0E}", underline = true }

          [which]
          mask = { bg = "${self.theme.base01}" }
          cand = { fg = "${self.theme.base0D}" }
          rest = { fg = "${self.theme.base0C}" }
          desc = { fg = "${self.theme.base0E}" }
          separator = "  "
          separator_style = { fg = "${self.theme.base03}" }

          [help]
          on = { fg = "${self.theme.base0D}" }
          run = { fg = "${self.theme.base0E}" }
          hovered = { reversed = true, bold = true }
          footer = { fg = "${self.theme.base01}", bg = "${self.theme.base06}" }

          [notify]
          title_info = { fg = "${self.theme.base0B}" }
          title_warn = { fg = "${self.theme.base0A}" }
          title_error = { fg = "${self.theme.base08}" }

          [filetype]
          rules = [
            { mime = "image/*", fg = "${self.theme.base0D}" },
            { mime = "{audio,video}/*", fg = "${self.theme.base0A}" },
            { mime = "application/{zip,rar,7z*,tar,gzip,xz,zstd,bzip*,lzma,compress,archive,cpio,arj,xar,ms-cab*}", fg = "${self.theme.base0E}" },
            { mime = "application/{pdf,doc,rtf,odt,docx,xlsx,pptx}", fg = "${self.theme.base0B}" },

            { url = "*/", fg = "${self.theme.base0D}" },
            { url = "*", fg = "${self.theme.base06}" },
          ]
        '';
      };

      settings = {
        theme = {
          flavor = {
            dark = "myTheme";
            light = "myTheme";
          };
        };

        yazi = {
          plugin = {
            prepend_fetchers = [
              {
                id = "git";
                url = "*";
                run = "git";
                group = "git";
              }
              {
                id = "git";
                url = "*/";
                run = "git";
                group = "git";
              }
            ];
          };
        };

        keymap = {
          mgr = {
            prepend_keymap = [
              {
                on = "l";
                run = "plugin smart-enter";
                desc = "Enter the child directory, or open the file";
              }
              {
                on = [ "<C-d>" ];
                run = "plugin drag";
                desc = "Drag selected files out to another app";
              }
              {
                on = "+";
                run = "plugin zoom 1";
                desc = "Zoom in the hovered image";
              }
              {
                on = "-";
                run = "plugin zoom -1";
                desc = "Zoom out the hovered image";
              }
              {
                on = [ "M" ];
                run = "plugin gvfs -- select-then-mount";
                desc = "Select a device then mount it over gvfs";
              }
            ];
          };
        };
      };

      # gvfs.yazi requires an explicit setup() call to do anything at all;
      # git.yazi's is optional (only controls sign ordering) but cheap to set.
      constructFiles.init = {
        relPath = "${config.binName}-config/init.lua";
        output = config.generatedConfig.output;
        content = ''
          require("git"):setup({ order = 1500 })
          require("gvfs"):setup({})
        '';
      };
    };

  perSystem =
    { pkgs, ... }:
    {
      packages.yazi = inputs.wrapper-modules.wrappers.yazi.wrap {
        inherit pkgs;
        imports = [ self.wrappersModules.yazi ];
      };
    };
}
