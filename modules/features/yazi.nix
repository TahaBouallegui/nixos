{ self, inputs, ... }: {
  perSystem =
    { pkgs, ... }:

    let
      # Generate the tmTheme file from your theme colors
      myTmTheme = pkgs.writeTextFile {
        name = "myTheme.tmTheme";
        text = ''
          <?xml version="1.0" encoding="UTF-8"?>
          <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
          <plist version="1.0">
          <dict>
            <key>name</key>
            <string>My Theme</string>
            <key>settings</key>
            <array>
              <dict>
                <key>settings</key>
                <dict>
                  <key>background</key>
                  <string>${self.theme.base00}</string>
                  <key>foreground</key>
                  <string>${self.theme.base05}</string>
                  <key>caret</key>
                  <string>${self.theme.base05}</string>
                  <key>selection</key>
                  <string>${self.theme.base02}</string>
                  <key>invisibles</key>
                  <string>${self.theme.base03}</string>
                  <key>lineHighlight</key>
                  <string>${self.theme.base01}</string>
                </dict>
              </dict>
              # Comments
              <dict>
                <key>name</key>
                <string>Comment</string>
                <key>scope</key>
                <string>comment</string>
                <key>settings</key>
                <dict>
                  <key>foreground</key>
                  <string>${self.theme.base03}</string>
                </dict>
              </dict>
              # Strings
              <dict>
                <key>name</key>
                <string>String</string>
                <key>scope</key>
                <string>string</string>
                <key>settings</key>
                <dict>
                  <key>foreground</key>
                  <string>${self.theme.base0B}</string>
                  <key>fontStyle</key>
                  <string>italic</string>
                </dict>
              </dict>
              # Keywords
              <dict>
                <key>name</key>
                <string>Keyword</string>
                <key>scope</key>
                <string>keyword</string>
                <key>settings</key>
                <dict>
                  <key>foreground</key>
                  <string>${self.theme.base08}</string>
                </dict>
              </dict>
              # Functions
              <dict>
                <key>name</key>
                <string>Function</string>
                <key>scope</key>
                <string>entity.name.function, meta.function, support.function</string>
                <key>settings</key>
                <dict>
                  <key>foreground</key>
                  <string>${self.theme.base0B}</string>
                  <key>fontStyle</key>
                  <string>italic,bold</string>
                </dict>
              </dict>
              # Types
              <dict>
                <key>name</key>
                <string>Type</string>
                <key>scope</key>
                <string>entity.name.type, entity.name.class, support.type, storage.type</string>
                <key>settings</key>
                <dict>
                  <key>foreground</key>
                  <string>${self.theme.base0A}</string>
                </dict>
              </dict>
              # Numbers
              <dict>
                <key>name</key>
                <string>Number</string>
                <key>scope</key>
                <string>constant.numeric</string>
                <key>settings</key>
                <dict>
                  <key>foreground</key>
                  <string>${self.theme.base0E}</string>
                </dict>
              </dict>
              # Operators
              <dict>
                <key>name</key>
                <string>Operator</string>
                <key>scope</key>
                <string>keyword.operator</string>
                <key>settings</key>
                <dict>
                  <key>foreground</key>
                  <string>${self.theme.base09}</string>
                </dict>
              </dict>
              # Variables
              <dict>
                <key>name</key>
                <string>Variable</string>
                <key>scope</key>
                <string>variable, variable.parameter, variable.other</string>
                <key>settings</key>
                <dict>
                  <key>foreground</key>
                  <string>${self.theme.base0D}</string>
                </dict>
              </dict>
              # Preprocessor
              <dict>
                <key>name</key>
                <string>Preprocessor</string>
                <key>scope</key>
                <string>meta.preprocessor, entity.name.function.preprocessor</string>
                <key>settings</key>
                <dict>
                  <key>foreground</key>
                  <string>${self.theme.base0C}</string>
                </dict>
              </dict>
            </array>
          </dict>
          </plist>
        '';
      };
    in
    {
      packages.yazi = inputs.wrapper-modules.wrappers.yazi.wrap {
        inherit pkgs;
        flavors = {
          "myTheme" = pkgs.writeTextFile {
            name = "myTheme";
            text = ''
              # Status bar separators (keep empty for a clean look)
              [status]
              separator_open = ""
              separator_close = ""

              # Normal mode – matches lualine normal.a (blue)
              [status.mode_normal]
              fg = "${self.theme.base00}"
              bg = "${self.theme.base0D}"

              # Insert mode – matches lualine insert.a (green)
              [status.mode_insert]
              fg = "${self.theme.base00}"
              bg = "${self.theme.base0B}"

              # Visual mode – matches lualine visual.a (yellow/magenta)
              [status.mode_visual]
              fg = "${self.theme.base00}"
              bg = "${self.theme.base0E}"

              # Input line (command entry) – same as Normal text
              [input]
              fg = "${self.theme.base06}"
              bg = "${self.theme.base00}"

              # Selection within input (e.g., autocomplete) – like PMenu
              [select]
              fg = "${self.theme.base06}"
              bg = "${self.theme.base02}"

              # Regular files – use the same foreground as Neovim's Normal
              [file]
              fg = "${self.theme.base06}"

              # Directories – blue (like Directory highlight)
              [directory]
              fg = "${self.theme.base0D}"

              # Symbolic links – cyan (like special)
              [symlink]
              fg = "${self.theme.base0C}"

              # Executable files – green (like Function)
              [executable]
              fg = "${self.theme.base0B}"

              # Selected items – bright text on blue background
              [selected]
              fg = "${self.theme.base07}"
              bg = "${self.theme.base0D}"
            '';
          };
        };
        settings.theme.syntect-theme = myTmTheme;
      };
    };
}

