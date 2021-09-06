{ pkgs, config, lib, ... }:

{
  imports = [
    ../../modules/mautrix-whatsapp
  ];
  nixpkgs.overlays = [
    (import ../../overlays/riot-web.nix)
  ];

  services.postgresql.enable = true;
  # Try to create database

  services.matrix-synapse = {
    enable = true;
    enable_registration = true;
    server_name = "sene.ovh";
    listeners = [
      {
        bind_address = "127.0.0.1";
        port = 8008;
        resources = [
          {
            compress = false;
            names = [ "client" "federation" ];
          }
        ];
        tls = false;
        type = "http";
        x_forwarded = true;
      }
    ];
    database_type = "psycopg2";
    database_args = {
      database = "matrix-synapse";
    };
    tls_private_key_path = "/var/lib/acme/sene.ovh/key.pem";
    tls_certificate_path = "/var/lib/acme/sene.ovh/fullchain.pem";
    max_upload_size = "100M";
    url_preview_enabled = true;
  };
  users.groups.${toString(config.services.nginx.group)}.members = [ "matrix-synapse" ];

  services.mautrix-whatsapp = {
    enable = true;
    settings = {
      homeserver.address = "https://matrix.sene.ovh";
      bridge.permissions = {
        "@vskilet:sene.ovh" = "admin";
      };
    };
  };

  services.nginx.virtualHosts = {
    "riot.sene.ovh" = {
      enableACME = true;
      forceSSL = true;
      serverAliases = [ "chat.sene.ovh" "chat.stech.ovh" ];
      locations = { "/" = { root = pkgs.element-web; }; };
    };
    "matrix.sene.ovh" = {
      enableACME = true;
      forceSSL = true;
      locations."/".extraConfig = ''
        error_page 404 https://sene.ovh/errorpages/50x.html;
      '';
      locations."/_matrix" = {
        proxyPass = "http://127.0.0.1:8008";
      };
    };
  };
}
