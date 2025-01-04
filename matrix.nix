{ pkgs, lib, config, ... }:
let
  serverName = config.networking.domain;
  fqdn = "https://matrix.${serverName}";
in {
  age.secrets.matrix-synapse-config = {
    file = ./secrets/matrix-synapse-config.age;
    path = "/var/lib/matrix-synapse/secrets-config.yml";
    owner = "matrix-synapse";
    group = "matrix-synapse";
    mode = "600";
  };

  age.secrets.matrix-synapse-signing = {
    file = ./secrets/matrix-synapse-signing.age;
    path = "/var/lib/matrix-synapse/homeserver.signing.key";
    owner = "matrix-synapse";
    group = "matrix-synapse";
    mode = "600";
  };

  security.acme.certs."nullablevo.id.au" = {
    extraDomainNames = [ "matrix.nullablevo.id.au" ];
  };

  services.postgresql = {
    enable = true;
    ensureDatabases = [ "matrix-synapse" ];
    ensureUsers = [{
      name = "matrix-synapse";
      ensureDBOwnership = true;
    }];
  };

  services.matrix-synapse = {
    enable = true;

    settings = {
      server_name = serverName;
      public_baseurl = fqdn;

      database.name = "psycopg2";

      listeners = [{
        port = 8008;
        bind_addresses = [ "::1" ];
        type = "http";
        tls = false;
        x_forwarded = true;
        resources = [{
          names = [ "client" "federation" ];
          compress = true;
        }];
      }];

      signing_key_path = config.age.secrets.matrix-synapse-signing.path;
      extraConfigFiles = [ config.age.secrets.matrix-synapse-config.path ];
    };
  };
}
