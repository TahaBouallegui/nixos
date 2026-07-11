{ self, inputs, ... }: {
  perSystem = { pkgs, ... }: {
    packages.yazi = inputs.wrapper-modules.wrappers.yazi.wrap {
      inherit pkgs;

      plugins = with pkgs.yaziPlugins; {
        drag = drag;
        git = git;
        smart-enter = smart-enter;
        gvfs = gvfs;
        zoom = zoom;
      };

      flavors = {
        "myTheme" = pkgs.writeTextFile {
          name = "myTheme";
          text = ''
            [theme]
            base00 = "${self.theme.base00}"
            base01 = "${self.theme.base01}"
            base02 = "${self.theme.base02}"
            base03 = "${self.theme.base03}"
            base04 = "${self.theme.base04}"
            base05 = "${self.theme.base05}"
            base06 = "${self.theme.base06}"
            base07 = "${self.theme.base07}"
            base08 = "${self.theme.base08}"
            base09 = "${self.theme.base09}"
            base0A = "${self.theme.base0A}"
            base0B = "${self.theme.base0B}"
            base0C = "${self.theme.base0C}"
            base0D = "${self.theme.base0D}"
            base0E = "${self.theme.base0E}"
            base0F = "${self.theme.base0F}"

            [status]
            separator_open = ""
            separator_close = ""

            [status.mode_normal]
            fg = "${self.theme.base00}"
            bg = "${self.theme.base0D}"

            [status.mode_insert]
            fg = "${self.theme.base00}"
            bg = "${self.theme.base0B}"

            [status.mode_visual]
            fg = "${self.theme.base00}"
            bg = "${self.theme.base0E}"

            [input]
            fg = "${self.theme.base06}"
            bg = "${self.theme.base00}"

            [select]
            fg = "${self.theme.base06}"
            bg = "${self.theme.base02}"

            [file]
            fg = "${self.theme.base06}"

            [directory]
            fg = "${self.theme.base0D}"

            [symlink]
            fg = "${self.theme.base0C}"

            [executable]
            fg = "${self.theme.base0B}"

            [selected]
            fg = "${self.theme.base07}"
            bg = "${self.theme.base0D}"
          '';
        };
      };
    };
  };
}
