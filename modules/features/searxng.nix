{ self, flake, ... }:
{
  flake.nixos.nixosModules.searxng = { config, lib, ... }: {
    services = {
      searx = {
        enable = true;
        redisCreateLocally = true;
        settings.server = {
          bind_address = "::1";
          port = 8902;

          engines = lib.mapAttrsToList (name: value: { inherit name; } // value) {
            "duckduckgo".disabled = true;
            "brave".disabled = true;
            "bing".disabled = false;
            "mojeek".disabled = true;
            "mwmbl".disabled = false;
            "mwmbl".weight = 0.4;
            "qwant".disabled = true;
            "crowdview".disabled = false;
            "crowdview".weight = 0.5;
            "curlie".disabled = true;
            "ddg definitions".disabled = false;
            "ddg definitions".weight = 2;
            "wikibooks".disabled = false;
            "wikidata".disabled = false;
            "wikiquote".disabled = true;
            "wikisource".disabled = true;
            "wikispecies".disabled = false;
            "wikispecies".weight = 0.5;
            "wikiversity".disabled = false;
            "wikiversity".weight = 0.5;
            "wikivoyage".disabled = false;
            "wikivoyage".weight = 0.5;
            "currency".disabled = true;
            "dictzone".disabled = true;
            "lingva".disabled = true;
            "bing images".disabled = false;
            "brave.images".disabled = true;
            "duckduckgo images".disabled = true;
            "google images".disabled = false;
            "qwant images".disabled = true;
            "1x".disabled = true;
            "artic".disabled = false;
            "deviantart".disabled = false;
            "flickr".disabled = true;
            "imgur".disabled = false;
            "library of congress".disabled = false;
            "material icons".disabled = true;
            "material icons".weight = 0.2;
            "openverse".disabled = false;
            "pinterest".disabled = true;
            "svgrepo".disabled = false;
            "unsplash".disabled = false;
            "wallhaven".disabled = false;
            "wikicommons.images".disabled = false;
            "yacy images".disabled = true;
            "bing videos".disabled = false;
            "brave.videos".disabled = true;
            "duckduckgo videos".disabled = true;
            "google videos".disabled = false;
            "qwant videos".disabled = false;
            "dailymotion".disabled = true;
            "google play movies".disabled = true;
            "invidious".disabled = true;
            "odysee".disabled = true;
            "peertube".disabled = false;
            "piped".disabled = true;
            "rumble".disabled = false;
            "sepiasearch".disabled = false;
            "vimeo".disabled = true;
            "youtube".disabled = false;
            "brave.news".disabled = true;
            "google news".disabled = true;
          };
          enabled_plugins = [
            "Hash plugin"
            "Tor check plugin"
            "Open Access DOI rewrite"
            "Hostnames plugin"
            "Tracker URL remover"
          ];
        };
      };
    };
  };
}
