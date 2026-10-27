{ self, ... }:
{
  # btop goes through wrapper-modules (nix-wrapper-modules) so its theme
  # can be generated from flake.theme -- one palette for the whole desktop
  # (modules/features/theme.nix). The wrapper passes `--config` and
  # `--themes-dir` on every invocation, so ~/.config/btop can never drift
  # the colors. `color_theme` names the file in `themes` (verified: btop
  # 1.4.7 loads plain names from --themes-dir).
  flake.wrappersModules.btop =
    { ... }:
    let
      t = self.theme;
    in
    {
      settings.color_theme = "mocha";

      themes.mocha = ''
        theme[main_bg]="${t.base00}"
        theme[main_fg]="${t.base06}"
        theme[title]="${t.base07}"
        theme[hi_fg]="${t.base0D}"
        theme[selected_bg]="${t.base0E}"
        theme[selected_fg]="${t.base00}"
        theme[inactive_fg]="${t.base03}"
        theme[graph_text]="${t.base05}"
        theme[meter_bg]="${t.base02}"
        theme[proc_misc]="${t.base0E}"
        theme[cpu_box]="${t.base0D}"
        theme[mem_box]="${t.base0B}"
        theme[net_box]="${t.base0C}"
        theme[proc_box]="${t.base0E}"
        theme[div_line]="${t.base02}"
        theme[temp_start]="${t.base0A}"
        theme[temp_mid]="${t.base09}"
        theme[temp_end]="${t.base08}"
        theme[cpu_start]="${t.base0D}"
        theme[cpu_mid]="${t.base0C}"
        theme[cpu_end]="${t.base0B}"
        theme[free_start]="${t.base04}"
        theme[free_mid]="${t.base0C}"
        theme[free_end]="${t.base0B}"
        theme[cached_start]="${t.base03}"
        theme[cached_mid]="${t.base04}"
        theme[cached_end]="${t.base05}"
        theme[available_start]="${t.base0A}"
        theme[available_mid]="${t.base09}"
        theme[available_end]="${t.base09}"
        theme[used_start]="${t.base0B}"
        theme[used_mid]="${t.base0A}"
        theme[used_end]="${t.base08}"
        theme[download_start]="${t.base04}"
        theme[download_mid]="${t.base0C}"
        theme[download_end]="${t.base0D}"
        theme[upload_start]="${t.base08}"
        theme[upload_mid]="${t.base09}"
        theme[upload_end]="${t.base0A}"
        theme[process_start]="${t.base04}"
        theme[process_mid]="${t.base0D}"
        theme[process_end]="${t.base0E}"
      '';
    };
}
