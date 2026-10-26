{ self, flake, ... }:
{
  flake.nixosModules.searxng = { ... }: {
    services.searx = {
      enable = true;
      redisCreateLocally = true;
      settings = {
        search.formats = [ "html" "json" ];

        # With default_lang = "auto" and no Accept-Language header (the DSH
        # web-search client sends none), SearXNG resolves the language to
        # "all", and DuckDuckGo then answers with a CAPTCHA:
        # https://github.com/searxng/searxng/issues/6779
        search.default_lang = "en-US";

        # The default `general` pool is brave + duckduckgo + google cse, and
        # from this host all three are dead: Brave answers HTTP 429 ("too many
        # requests", still failing after 200 s of quiet) and Google refuses the
        # IP. duckduckgo was the only engine left serving `general`, and it
        # CAPTCHAs about half the time, so ~half of all searches returned zero
        # results. The engines below were probed on 2026-10-13 with
        # /search?format=json&engines=<name>; the comment is the measured
        # result count for the same query.
        engines = [
          { name = "bing"; disabled = false; }           # 10
          { name = "yandex"; disabled = false; }         # 15
          { name = "yahoo"; disabled = false; }          # 7
          { name = "gmx"; disabled = false; }            # 10
          { name = "yep"; disabled = false; }            # 20
          { name = "duckduckgo web"; disabled = false; } # 10
          # Shared-key CSE only ever answers "unusual traffic" here.
          { name = "google cse"; disabled = true; }
        ];
      };
      settings.server = {
        bind_address = "0.0.0.0";
        port = 8900;
        secret_key = "lingangu";
      };
    };
  };
}
