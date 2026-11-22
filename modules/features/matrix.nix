{self, ...}: {
  flake.nixosModules.matrix = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.matrix;
    # Everything a client touches goes through nginx: synapse itself only
    # listens on localhost. 8080 is the public (tailnet) entry point.
    baseUrl = "http://${cfg.serverName}:8080";
  in {
    options.matrix.serverName = lib.mkOption {
      type = lib.types.str;
      description = ''
        Matrix server_name for this homeserver. It is baked into every
        user ID (@user:<serverName>) and can never be changed afterwards
        -- if the server might ever go public, put the future domain here
        from day one.
      '';
    };

    config = {
      # The module defaults to the psycopg2 backend (stateVersion >= 18.03);
      # these two lines are the declarative form of the manual
      # CREATE ROLE/CREATE DATABASE step in the nixpkgs matrix docs.
      # Synapse connects over the unix socket, so peer auth needs no password.
      services.postgresql = {
        enable = true;
        ensureUsers = [
          {name = "matrix-synapse";}
        ];
        ensureDatabases = ["matrix-synapse"];
      };

      services.matrix-synapse = {
        enable = true;

        # register_new_matrix_user on PATH -- the closed-registration story:
        # nobody can self-register, accounts are made on the host with the
        # shared secret. See the preStart block below for the secret file.
        enableRegistrationScript = true;

        settings = {
          server_name = cfg.serverName;
          public_baseurl = baseUrl;

          enable_registration = false;

          listeners = [
            {
              port = 8008;
              # localhost only -- the nginx vhost below is the only front door.
              bind_addresses = [
                "127.0.0.1"
                "::1"
              ];
              type = "http";
              tls = false;
              x_forwarded = true;
              resources = [
                {
                  names = [
                    "client"
                    "federation"
                  ];
                  compress = true;
                }
              ];
            }
          ];

          # Outbound federation works (synapse dials out); inbound cannot,
          # since nothing public can reach this box. Chatting with users on
          # other homeservers through shared rooms still works best-effort.
          allow_federation = true;
        };

        # The registration secret must NOT go through the nix store
        # (AGENTS.md hard rule), so it is generated once into the service
        # state dir at first start and included via --config-path.
        extraConfigFiles = ["/var/lib/matrix-synapse/registration-secret.yaml"];
      };

      # Create the secret on first activation, as the service user, 0600.
      systemd.services.matrix-synapse.preStart = lib.mkAfter ''
        if [ ! -e /var/lib/matrix-synapse/registration-secret.yaml ]; then
          (umask 077; printf 'registration_shared_secret: %s\n' "$(${pkgs.openssl}/bin/openssl rand -hex 32)" > /var/lib/matrix-synapse/registration-secret.yaml)
        fi
      '';

      services.nginx = {
        enable = true;
        recommendedGzipSettings = true;
        recommendedProxySettings = true;
        virtualHosts = {
          # Tailnet-only by construction: no firewall port is opened, so
          # this is reachable only via the trusted tailscale0 interface
          # (same posture as searxng). Element devs advise against serving
          # the client on the same origin as the homeserver; on a
          # tailnet-only box that trade is acceptable -- revisit if this
          # ever gets a public domain.
          "${cfg.serverName}" = {
            listen = [
              {
                addr = "0.0.0.0";
                port = 8080;
              }
              {
                addr = "::";
                port = 8080;
              }
            ];
            root = pkgs.element-web.override {
              conf = {
                default_server_config."m.homeserver".base_url = baseUrl;
              };
            };
            locations."= /.well-known/matrix/client".extraConfig = ''
              default_type application/json;
              add_header Access-Control-Allow-Origin *;
              return 200 '${builtins.toJSON {"m.homeserver".base_url = baseUrl;}}';
            '';
            # A trailing slash must NOT be used for the /_matrix proxy.
            locations."/_matrix".proxyPass = "http://[::1]:8008";
            locations."/_synapse/client".proxyPass = "http://[::1]:8008";
          };
        };
      };
    };
  };
}
