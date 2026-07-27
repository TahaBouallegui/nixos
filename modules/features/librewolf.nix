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
            "privacy.donottrackheader.enabled" = true;
            "privacy.fingerprintingProtection" = true;
            "privacy.resistFingerprinting" = true;
            "privacy.trackingprotection.emailtracking.enabled" = true;
            "privacy.trackingprotection.enabled" = true;
            "privacy.trackingprotection.fingerprinting.enabled" = true;
            "privacy.trackingprotection.socialtracking.enabled" = true;
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
      environment.systemPackages = [ element ];
    };
}
