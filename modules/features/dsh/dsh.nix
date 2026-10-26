{ self, inputs, ... }:
{
  flake.nixosModules.dsh =
    { config, pkgs, ... }:
    let
      profilePackages = self.packages.${pkgs.stdenv.hostPlatform.system};
    in
    {
      imports = [ inputs.deepseek-harness.nixosModules.default ];

      programs.dsh = {
        enable = true;

        # DeepSeek Harness Desktop (system tray app) running this profile.
        desktop = {
          enable = true;
          profile = config.programs.dsh.profiles.desktop.materializedName;

          # The white bar is not GNOME: Electron defaults to X11, so under
          # niri the window is served by xwayland-satellite, which draws a
          # white Adwaita-light title bar, and Electron itself paints an
          # always-visible "Application" menu bar below it. Native Wayland
          # (ELECTRON_OZONE_PLATFORM_HINT) + niri's top-level prefer-no-csd
          # drops the frame; autoHideMenuBar hides the menu strip (Alt still
          # reveals it, accelerators keep working).
          package = pkgs.dsh.dsh-desktop-official.overrideAttrs (
            finalAttrs: previousAttrs:
            {
              preFixup = previousAttrs.preFixup + ''
                gappsWrapperArgs+=(--set ELECTRON_OZONE_PLATFORM_HINT auto)
              '';
              # The agent-preset picker renders `name`/`description` straight from
              # the plugin's preset.yml — unlike the lever and settings copy, they
              # are not i18n'd, so they stay Chinese whatever the UI locale is.
              postInstall = previousAttrs.postInstall or "" + ''
                substituteInPlace "$appDir/resources/app/lib/main.js" \
                  --replace-fail 'minHeight: 600,' 'minHeight: 600, autoHideMenuBar: true,'

                substituteInPlace "$appDir/resources/app/dsh/node_modules/@linxin666/dsh-liangshen/presets/liangshen/preset.yml" \
                  --replace-fail 'name: 梁神模式' 'name: LiangShen mode (梁神模式)' \
                  --replace-fail 'description: 那模式一启动，使用者当场双腿一软瘫坐在地，仿佛看见原子弹爆炸——三秒，三辈子的代码，外加文言文、二进制、摩斯电码三语解说轮番轰炸，凡人最后只能趴在地上用下巴磕出两个字:梁神！' \
                  'description: The moment this mode starts, your legs give out and you collapse to the floor as if watching a nuclear detonation: three seconds, three generations of code, plus a trilingual barrage of Classical Chinese, binary and Morse code. A mere mortal can only lie flat on the ground and hammer out two words with their chin - LiangShen!'
              '';
            }
          );
        };

        # The `dsh` CLI picks this profile when launched without --profile.
        defaultProfile = config.programs.dsh.profiles.desktop.materializedName;

        profiles.desktop = {
          # Keep the default `managed` mode so Nix owns the profile directory.
          # web-ui pulls in the whole client-UI superset (market, git-graph,
          # skill-explorer, task-board, inspector, session titles, …); the
          # desktop profile gets web-app automatically via requiresWeb.
          bundles = [
            pkgs.dsh.bundles.base
            pkgs.dsh.bundles.web-app
            pkgs.dsh.bundles.web-ui
            pkgs.dsh.bundles.genui
            profilePackages.dsh-web-search-searxng
            profilePackages.dsh-rewind-plugin
            profilePackages.billion-context
            profilePackages.dsh-extra-sandbox-presets
          ];

          # Mirrors the live Web profile's cordis.patch.yml (minus the two
          # @local plugin rows, which are not in this profile's bundles).
          # Nix serialises this list to ~/.dsh/profiles/nix-desktop/cordis.patch.yml
          # on every activation.
          patch = [
            # The bundle layer inserts this row config-less; patch it by id.
            # Do NOT insert a second row with the same id (duplicate loader
            # entry id = silent double-mount + blocks dshmarket updates).
            {
              id = "web-search-searxng";
              config = {
                baseURL = "http://127.0.0.1:8900/";
                maxResults = 10;
              };
            }

            {
              id = "web";
              config = {
                fetchProvider = "http";
                searchProvider = "searxng";
              };
            }

            # Always-writable extra sandbox roots.
            {
              id = "extra-sandbox-presets";
              config = {
                presets = {
                  workspace-write-extra = {
                    writableDirs = [
                      "~/.cache/nix"
                      "~/.local/state/nix"
                    ];
                  };
                };
              };
            }

            # This plugin's patch semantics REPLACE the whole config object
            # per id, so the base bundle's preset table is restated here.
            # workspace-write-extra is also restated statically: the
            # constructor eagerly resolves defaultPreset against this table
            # (dsh-permission-presets lib/index.js:181) and
            # dsh-extra-sandbox-presets only publishes its entry after
            # construction — without this entry the defaultPreset throws
            # "unknown preset". The static entry mirrors the published one
            # exactly (sandbox: workspace-write, approval: ask).
            {
              id = "permission";
              config = {
                presets = {
                  read-only = {
                    sandbox = "read-only";
                    approval = "ask";
                  };
                  workspace-write = {
                    sandbox = "workspace-write";
                    approval = "ask";
                  };
                  workspace-write-extra = {
                    sandbox = "workspace-write";
                    approval = "ask";
                  };
                  danger-full-access = {
                    sandbox = "danger-full-access";
                    approval = "never";
                  };
                };
                defaultPreset = "workspace-write-extra";
              };
            }

            # Fully disable session telemetry (no capture, no OTLP export).
            {
              id = "session-telemetry-otel";
              config = {
                mode = "DISABLED";
              };
            }

            # Longer tool-call timeout window (local-model sessions run long
            # shell commands/builds and slower web fetches).
            {
              id = "bash-sandbox";
              config = {
                timeoutMs = 600000;
              };
            }

            {
              id = "tool-web";
              config = {
                fetch = true;
                searchTimeoutMs = 600000;
              };
            }

            # mcp-nixos (nixpkgs#mcp-nixos): real NixOS/nixpkgs option search
            # over MCP instead of guessing option names.
            {
              insert = [
                {
                  id = "mcp-nixos";
                  name = "@deepseek-ai/dsh-mcp-client";
                  config = {
                    transport = "stdio";
                    serverName = "nixos";
                    command = "nix";
                    args = [
                      "run"
                      "nixpkgs#mcp-nixos"
                      "--"
                    ];
                    toolCallTimeoutMs = 600000;
                  };
                }
              ];
            }

            {
              id = "ui-settings-general";
              name = "@deepseek-ai/dsh-client-ui-settings-general";
              config = {
                welcomeNoticeVersion = "2026-09-28.1";
              };
            }

            {
              id = "llm-pi-ai";
              name = "@deepseek-ai/dsh-llm-pi-ai";
              config = {
                providers = {
                  zabeth24 = {
                    displayName = "zabeth24";
                    apiKeyEnv = "ZABETH24_API_KEY";
                    api = "openai-completions";
                    baseURL = "http://zabeth24.tail5481a4.ts.net:8080/v1";
                    models = [
                      {
                        id = "peculiar-ragdoll/Tiel-Coder-35B-A3B-GGUF-MTP:UD-Q4_K_XL";
                        name = "peculiar-ragdoll/Tiel-Coder-35B-A3B-GGUF-MTP:UD-Q4_K_XL";
                        input = [
                          "text"
                          "image"
                        ];
                      }
                      {
                        id = "ISTA-DASLab/Qwen3.8-Flash-Next-GSQ-RCO-GGUF:IQ3_S";
                        name = "ISTA-DASLab/Qwen3.8-Flash-Next-GSQ-RCO-GGUF:IQ3_S";
                        input = [
                          "text"
                          "image"
                        ];
                      }
                      {
                        id = "qwen3.8-flash-next-iq3_s";
                        name = "qwen3.8-flash-next-iq3_s";
                        input = [
                          "text"
                          "image"
                        ];
                      }
                    ];
                    timeoutMs = 900000;
                    streamIdleTimeoutMs = 900000;
                  };
                  zabeth23 = {
                    displayName = "zabeth23";
                    apiKeyEnv = "ZABETH23_API_KEY";
                    api = "openai-completions";
                    baseURL = "http://zabeth23.tail5481a4.ts.net:8080/v1";
                    models = [
                      {
                        id = "qwen3.8-flash-next-iq3_s";
                        name = "qwen3.8-flash-next-iq3_s";
                        maxTokens = 64000;
                        input = [
                          "text"
                          "image"
                        ];
                      }
                    ];
                  };
                };
              };
            }

            {
              id = "agent-default-model";
              name = "@deepseek-ai/dsh-agent-default-model";
              config = {
                provider = "zabeth23";
                model = "qwen3.8-flash-next-iq3_s";
              };
            }

            {
              id = "ui-theme";
              name = "@deepseek-ai/dsh-client-ui-theme";
              config = {
                preference = "dark";
              };
            }

            {
              id = "session-log-deepseek";
              name = "@deepseek-ai/dsh-session-log-deepseek";
              config = {
                enabled = false;
              };
            }
          ];
        };
      };

      # Placeholder keys for the tailscale-only llama.cpp endpoints; the real
      # values are dummy ("x") on these boxes, kept out of the LLM config UI.
      environment.sessionVariables = {
        ZABETH23_API_KEY = "x";
        ZABETH24_API_KEY = "x";
      };
    };
}
