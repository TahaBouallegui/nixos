{ self, inputs, ... }: {
  flake.nixosModules.zen-browser =
    { config, pkgs, ... }:

    let
      # Define the hardened preferences (about:config settings)
      hardenedPrefs = {
        # --- Fingerprinting Protection ---
        "privacy.resistFingerprinting" = true; # RFP - best anti-fingerprinting
        "privacy.fingerprintingProtection" = true; # Additional fingerprinting protection
        "webgl.disabled" = true; # WebGL is a strong fingerprinting vector
        "privacy.spoof_english" = 2; # Spoof OS language to en-US

        # --- Cookies & Data ---
        "network.cookie.lifetimePolicy" = 2; # Delete cookies on close
        "privacy.clearOnShutdown.cookies" = true;
        "privacy.clearOnShutdown.history" = true;
        "privacy.clearOnShutdown.cache" = true;
        "privacy.clearOnShutdown.sessions" = true;
        "privacy.clearOnShutdown.offlineApps" = true;
        "privacy.clearOnShutdown.downloads" = true;
        "privacy.clearOnShutdown.formdata" = true;
        "network.cookie.thirdparty.sessionOnly" = true; # Third-party cookies session-only
        "network.cookie.thirdparty.nonsecureSessionOnly" = true;

        # --- Tracking Protection ---
        "privacy.trackingprotection.enabled" = true; # Enable tracking protection
        "privacy.trackingprotection.pbmode.enabled" = true;
        "privacy.trackingprotection.fingerprinting.enabled" = true;
        "privacy.trackingprotection.cryptomining.enabled" = true;
        "privacy.trackingprotection.socialtracking.enabled" = true;
        "privacy.donottrackheader.enabled" = true; # Send DNT header

        # --- Telemetry & Annoyances ---
        "datareporting.healthreport.uploadEnabled" = false;
        "datareporting.policy.dataSubmissionEnabled" = false;
        "toolkit.telemetry.enabled" = false;
        "toolkit.telemetry.unified" = false;
        "browser.ping-centre.telemetry" = false;
        "extensions.pocket.enabled" = false; # Disable Pocket

        # --- Network & Security ---
        "dom.security.https_only_mode" = true; # HTTPS-Only mode
        "dom.security.https_only_mode_ever_enabled" = true;
        "security.ssl.enable_ocsp_stapling" = true; # OCSP stapling for privacy
        "security.OCSP.require" = true; # OCSP hard-fail

        # --- Privacy Enhancements ---
        "privacy.firstparty.isolate" = true; # First-party isolation
        "privacy.partition.network_state" = true; # Network partitioning
        "privacy.query_stripping.enabled" = true; # Strip tracking from URLs
        "network.http.referer.XOriginPolicy" = 2; # Trim cross-origin referers
        "network.http.referer.trimmingPolicy" = 2;
        "network.prefetch-next" = false; # Disable link prefetching
        "network.dns.disablePrefetch" = true;
        "browser.urlbar.suggest.history" = false; # Disable search history
        "browser.urlbar.suggest.bookmark" = false;
        "browser.urlbar.suggest.openpage" = false;
        "browser.formfill.enable" = false; # Disable form autofill
      };

      # Define extensions to install (uBlock Origin is essential)
      extensions = [
        {
          name = "uBlock0@raymondhill.net";
          value = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
            installation_mode = "normal_installed";
          };
        }
        # Bitwarden - Password Manager
        {
          name = "{446900e4-71c2-419f-a6a7-df9c091e268b}"; # Bitwarden add-on ID
          value = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
            installation_mode = "normal_installed";
          };
        }
        # SponsorBlock - Skip sponsorships on YouTube
        {
          name = "sponsorBlocker@ajay.app"; # SponsorBlock add-on ID
          value = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/sponsorblock/latest.xpi";
            installation_mode = "normal_installed";
          };
        }
        # YouTube NonStop - Auto-click "Continue watching?" prompts
        {
          name = "{316cb7eb-36d4-4cc7-a77c-61b6998e7505}"; # YouTube NonStop add-on ID
          value = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/youtube-nonstop/latest.xpi";
            installation_mode = "normal_installed";
          };
        }
        # Zen Internet - Custom CSS injector for Zen Browser
        {
          name = "{91aa3897-2634-4a8a-9092-279db23a7689}"; # Zen Internet add-on ID
          value = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/zen-internet/latest.xpi";
            installation_mode = "normal_installed";
          };
        }
        # Dark Reader - Dark mode for every website
        {
          name = "addon@darkreader.org"; # Dark Reader add-on ID
          value = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
            installation_mode = "normal_installed";
          };
        }
      ];

    in
    {
      # System-wide installation
      environment.systemPackages = [
        (pkgs.wrapFirefox
          inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.zen-browser-unwrapped
          {
            # Lock preferences so they cannot be changed via about:config
            extraPrefs = builtins.concatStringsSep "\n" (
              builtins.map (
                name: "lockPref(\"${name}\", ${builtins.toJSON (builtins.getAttr name hardenedPrefs)});"
              ) (builtins.attrNames hardenedPrefs)
            );

            extraPolicies = {
              # Disable telemetry and studies
              DisableTelemetry = true;
              DisableFirefoxStudies = true;
              DisablePocket = true;
              DisableFeedbackCommands = true;
              DisableFirefoxAccounts = false; # Set to true if you don't use sync

              # Install extensions
              ExtensionSettings = builtins.listToAttrs extensions;

              # Set default search engine to DuckDuckGo
              SearchEngines = {
                Default = "DuckDuckGo";
                Remove = [
                  "Google"
                  "Bing"
                  "Amazon.com"
                  "eBay"
                  "Twitter"
                  "Wikipedia (en)"
                ];
                Add = [
                  {
                    Name = "DuckDuckGo";
                    URLTemplate = "https://duckduckgo.com/?q={searchTerms}";
                    IconURL = "https://duckduckgo.com/favicon.ico";
                    Alias = "@ddg";
                  }
                  {
                    Name = "Searx";
                    URLTemplate = "https://searx.be/search?q={searchTerms}";
                    IconURL = "https://searx.be/favicon.ico";
                    Alias = "@searx";
                  }
                ];
              };

              # Additional policies for hardening
              EnableTrackingProtection = {
                Value = true;
                Locked = true;
              };
              PasswordManagerEnabled = false; # Disable built-in password manager
              PrimaryPassword = false; # Don't prompt for primary password
              DisableFormHistory = true;
              DisableMasterPasswordCreation = true;
              OfferToSaveLogins = false;
              OfferToSaveLoginsDefault = false;
            };
          }
        )
      ];
    };
}
