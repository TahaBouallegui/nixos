{ inputs, ... }:
{
  perSystem =
    { pkgs, lib, ... }:
    let
      # atb's pkgs don't carry the deepseek-harness overlay (only the NixOS
      # module does), so pull the dsh package scope in explicitly here.
      dshPkgs = pkgs.appendOverlays [ inputs.deepseek-harness.overlays.default ];

      # The npm tarballs below ship no lockfile, so the default npmConfigHook
      # (`npm ci`) has nothing to work with. The hook registers itself via
      # `postPatchHooks+=(npmConfigHook)`, so the only way to skip it is to
      # swap in a hook derivation that does nothing.
      skipNpmConfigHook = dshPkgs.makeSetupHook {
        name = "dsh-prebuilt-skip-config-hook";
      } (dshPkgs.writeShellScript "skip-config" "true");

      # Prebuilt npm tarballs: the published files are already compiled, so
      # configure/build are skipped and the tree is copied verbatim. The
      # bundle ships no node_modules, so linkKernelNodeModules symlinks the
      # kernel's node_modules as the app dir's node_modules — every runtime
      # dep (zod, @deepseek-ai/cordis, @deepseek-ai/schemastery, …) resolves
      # through the kernel that way.
      prebuiltBundle =
        {
          pname,
          version,
          hash,
          description,
          homepage,
        }:
        dshPkgs.dsh.buildDshBundle (finalAttrs: {
          inherit pname version;

          src = dshPkgs.fetchzip {
            url = "https://registry.npmjs.org/${pname}/-/${pname}-${version}.tgz";
            inherit hash;
          };

          npmDeps = [ ];
          npmConfigHook = skipNpmConfigHook;
          dontBuild = true;

          linkKernelNodeModules = dshPkgs.dsh."dsh-kernel";

          installPhase = ''
            runHook preInstall

            appDir="$out/lib/node_modules/${pname}"
            mkdir -p "$appDir"
            cp -R . "$appDir"/

            runHook postInstall
          '';

          meta = {
            inherit description homepage;
            license = lib.licenses.mit;
            platforms = lib.platforms.unix;
          };
        });
    in
    {
      packages = {
        dsh-web-search-searxng = prebuiltBundle {
          pname = "dsh-web-search-searxng";
          version = "0.5.1";
          hash = "sha256-MLhPrii+q0shlk+KErryEleL+NZgfjZEU8PqMvXHnB4=";
          description = "SearXNG web search provider plugin for DeepSeek Harness";
          homepage = "https://github.com/chinng-inta/dsh-web-search-searxng";
        };

        dsh-rewind-plugin = prebuiltBundle {
          pname = "dsh-rewind-plugin";
          version = "0.15.3";
          hash = "sha256-k+7tlhOWY/kxYneNeTs+F9DkbzBB1zbYx5QXt+CuEn0=";
          description = "Conversation rewind plugin for DeepSeek Harness";
          homepage = "https://github.com/SiriLee/dsh-rewind";
        };

        billion-context = prebuiltBundle {
          pname = "billion-context";
          version = "0.1.197";
          hash = "sha256-GzSeZNCNJ7bzCYFeyQBd+IWS3Hkx77h5dI7fplMYmco=";
          description = "Hierarchical context compression plugin for DeepSeek Harness";
          homepage = "https://github.com/ranxianglei/billion-context";
        };

        # Built from source: the git dep pinned in the Web profile's
        # pnpm-lock.yaml has no prebuilt tarball on npm.
        dsh-extra-sandbox-presets = dshPkgs.dsh.buildDshBundle (finalAttrs: {
          pname = "dsh-extra-sandbox-presets";
          version = "0.3.0";

          src = dshPkgs.fetchFromGitHub {
            owner = "beicause";
            repo = "dsh-workspace-write-extra";
            rev = "df4a6d85ba9706359f165dbed00776cfe721c7f0";
            hash = "sha256-dVNHe64UJPL6mlO/eEDi/L8F7cgXQVL3OKQjZk9FH0Y=";
          };

          pnpmDeps = dshPkgs.dsh.fetchPnpmDeps {
            inherit (finalAttrs) pname version src;
            pnpm = dshPkgs.pnpm_11;
            fetcherVersion = 4;
            hash = "sha256-gw9GQV+R/RuIfVrIKsE3MeUH0S0uUBbaJxMUGGgM+zE=";
          };

          npmDeps = null;
          npmConfigHook = dshPkgs.pnpmConfigHook;
          npmBuildScript = "build";
          nativeBuildInputs = [ dshPkgs.pnpm_11 ];
          disallowedReferences = [ dshPkgs.pnpm_11 ];

          # Peer deps (@deepseek-ai/cordis, @deepseek-ai/schemastery) come
          # from the DSH kernel.
          linkKernelNodeModules = dshPkgs.dsh."dsh-kernel";

          installPhase = ''
            runHook preInstall

            appDir="$out/lib/node_modules/dsh-extra-sandbox-presets"
            mkdir -p "$appDir"
            cp -r package.json cordis.patch.yml lib README.md README.zh-CN.md "$appDir/"

            runHook postInstall
          '';

          meta = {
            description = "Extra writable sandbox preset plugin for DeepSeek Harness";
            homepage = "https://github.com/beicause/dsh-workspace-write-extra";
            license = lib.licenses.mit;
            platforms = lib.platforms.unix;
          };
        });
      };
    };
}
