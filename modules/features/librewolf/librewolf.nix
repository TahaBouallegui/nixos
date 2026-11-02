{
  flake.nixosModules.librewolf =
    { pkgs, ... }:
    let
      element = pkgs.makeDesktopItem {
        name = "element";
        exec = "librewolf --P apps --new-instance https://app.element.io/";
        desktopName = "Element";
        comment = "The element matrix client";
        startupWMClass = "Element";
      };
      userContent = ./userContent.css;
    in
    {
      programs.firefox = {
        enable = true;
        package = pkgs.librewolf;
        policies = {
          DisableTelemetry = true;
          DisableFirefoxStudies = true;
          Preferences = {
            "cookiebanners.service.mode.privateBrowsing" = 2; # Block cookie banners in private browsing
            "cookiebanners.service.mode" = 2; # Block cookie banners:
            "pdfjs.viewerCssTheme" = 2; # Built-in PDF.js viewer: 0 follow system, 1 light, 2 dark
            "privacy.donottrackheader.enabled" = true;
            "privacy.fingerprintingProtection" = true;
            "privacy.resistFingerprinting" = true;
            "privacy.trackingprotection.emailtracking.enabled" = true;
            "privacy.trackingprotection.enabled" = true;
            "privacy.trackingprotection.fingerprinting.enabled" = true;
            "privacy.trackingprotection.socialtracking.enabled" = true;
            # Must be a user value: the profile's chrome/ is read before a
            # default-value policy has been applied.
            "toolkit.legacyUserProfileCustomizations.stylesheets" = {
              Value = true;
              Status = "user";
            };
          };
          ExtensionSettings = {
            "jid1-ZAdIEUB7XOzOJw@jetpack" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/duckduckgo-for-firefox/latest.xpi";
              installation_mode = "force_installed";
            };
            "uBlock0@raymondhill.net" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
              installation_mode = "force_installed";
            };
            "addon@darkreader.org" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
              installation_mode = "force_installed";
            };
            "bitwarden@bitwarden.com" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
              installation_mode = "force_installed";
            };
          };
        };
      };

      # No programs.firefox option puts a userContent.css into a profile, and the
      # built-in PDF.js viewer can only be themed from one: it is an unobservable
      # document, so no @-moz-document selector can reach it. Link the themed file
      # into every profile directory (one holding a prefs.js); a profile with a
      # hand-written userContent.css is left alone.
      systemd.user.services.librewolf-pdf-theme = {
        description = "Link the themed userContent.css into every LibreWolf profile";
        wantedBy = [ "basic.target" ];
        serviceConfig = {
          Type = "oneshot";
        };
        path = [ pkgs.coreutils ];
        script = ''
          root="''${XDG_CONFIG_HOME:-$HOME/.config}/librewolf/librewolf"
          for p in "$root"/*/; do
            [ -f "''${p}prefs.js" ] || continue
            mkdir -p "''${p}chrome"
            css="''${p}chrome/userContent.css"
            if [ ! -e "$css" ] || [ -L "$css" ]; then
              ln -sfn ${userContent} "$css"
            fi
          done
        '';
      };

      environment.systemPackages = [ element ];
    };
}
