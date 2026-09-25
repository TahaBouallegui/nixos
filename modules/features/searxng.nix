{ self, flake, ... }:
{
  flake.nixos.nixosModules.searxng = { ... }: {
    services.searx = {
      enable = true;
      redisCreateLocally = true;
      settings = {
        search.formats = [ "html" "json" ];
      };
      settings.server = {
        bind_address = "0.0.0.0";
        port = 8900;
        secret_key = "lingangu";
      };
    };
  };
}
