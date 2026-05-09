# nixos/modules/features/dolphin.nix
{ self, inputs, lib, config, pkgs, ... }:

let
  # User that will get the declarative Dolphin config
  userName = "atb";
  userHome = "/home/${userName}";
  dolphinConfigDir = "${userHome}/.config";
  dolphinRc = "${dolphinConfigDir}/dolphinrc";

  # Basic theme adaptation – reuses your existing theme.nix values if available
  # (Fallback to a clean dark/light base if theme is not in scope)
  themeBase = if self ? theme then self.theme else {
    base00 = "#2e3440";   # dark background
    base01 = "#3b4252";
    base06 = "#e5e9f0";   # light text
  };
in
{
  flake.nixosModules.dolphin = { config, pkgs, ... }: {
    environment.systemPackages = with pkgs.kdePackages; [
      dolphin            # the file manager itself
      dolphin-plugins    # git integration, mount ISO, etc.
    ];

    # Declarative dolphinrc – written to the user's home directory
    systemd.tmpfiles.rules = [
      "d ${userHome}/.local/share/kxmlgui5/dolphin - ${userName} ${userName} - -"
      "f ${dolphinRc} 0644 ${userName} ${userName} - -"
    ];

    # Actual configuration that will be written
    environment.etc."dolphinrc".text = let
      inherit (lib) optionalString;
    in ''
      [General]
      ShowFullPath=true
      ShowSelectionToggle=true
      ShowZoomSlider=true
      EditableUrl=true
      FilterBar=true
      RememberOpenedTabs=false
      ShowStatusBar=true
      WindowSize=1024x768
      WordWrap=true
      ToolTipsEnabled=true

      [KFileDialog Settings]
      Show Hidden=false
      Automatic Completion=false
      Show Preview=true
      Show ToolTips=true
      Sort By=Name
      Sort Order=Ascending
      Show Hidden Files=false

      [PreviewSettings]
      # Enable previews for various file types
      Plugins=directorythumbnail,imagemagick,svg,raw,text,ffmpegthumbnailer,poppler
      ShowPreviews=true
      MaximumLocalFileSize=10485760  # 10 MB

      [MainWindow]
      ToolBars=dolphintoolbar,extraToolBar,mainToolBar
      State=AAAA/wAAAAD9AAAAAwAAAAAAAAD+AAAABAAAA3AA
      ToolBarsMovable=Disabled

      [Version Control]
      EnabledPlugins=git,subversion

      [View Defaults]
      # Icon size = 64px, sort by name ascending, show hidden files
      IconSize=64
      SortRole=Name
      SortOrder=Ascending
      Sort Folders First=true
      Show Hidden Files=false
      Show ToolTips=true
      Show Preview=true
      View Mode=Icons

      [Details Mode]
      Columns=Name,Size,Date,Type
      Show ToolTips=true

      [Icons Mode]
      Icon Size=64
      Text Below Icon=true

      [Columns Mode]
      Column Widths=180,80,120,100
      Sort Column=Name

      [Places Panel]
      # Visible places: Home, Root, Trash, Network, Removable Devices
      Visible Places=places:home,places:root,places:trash,places:network,places:removable
      Hidden Places=places:documents,places:music,places:pictures,places:videos
      Place Name=Home,Root,Trash,Network,Removable Devices

      [Context Menu]
      Services=org.kde.dolphin.services:NewMenu,org.kde.dolphin.services:OpenTerminal,org.kde.dolphin.services:GitMenu
      Show Copy Move=true
      Show Create New=true
      Show Open With=true
      Show Properties=true

      [Open Terminal]
      TerminalEmulator=${pkgs.kitty}/bin/kitty
      Use Current Directory=true
    '';

    # Additional session environment to ensure Dolphin respects the Nix theme
    # (optional – makes Dolphin adopt your Qt/GTK theme colours)
    environment.sessionVariables = {
      QT_STYLE_OVERRIDE = "kvantum";
      QT_QPA_PLATFORMTHEME = "qt5ct";
    };
  };
}
