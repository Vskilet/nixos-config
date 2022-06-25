{ pkgs, config, lib, ... }:

{
  imports = [
    ../../modules/mautrix-whatsapp
    ../../modules/mautrix-signal
  ];

  services.postgresql.enable = true;
  services.postgresql.initialScript = pkgs.writeText "synapse-init.sql" ''
    CREATE ROLE "matrix-synapse";
    CREATE DATABASE "matrix-synapse" WITH OWNER "matrix-synapse"
      TEMPLATE template0
      LC_COLLATE = "C"
      LC_CTYPE = "C";
  '';

  services.matrix-synapse = {
    enable = true;
    settings = {
      enable_registration = false;
      server_name = "sene.ovh";
      public_baseurl = "https://matrix.sene.ovh";
      listeners = [
        {
          bind_addresses = [
            "::"
            "0.0.0.0"
          ];
          port = 8008;
          tls = false;
          type = "http";
          x_forwarded = true;
          resources = [
            {
              compress = false;
              names = [ "client" "federation" ];
            }
          ];
        }
      ];
      database_type = "psycopg2";
      database_args = {
        database = "matrix-synapse";
      };
      tls_private_key_path = "/var/lib/acme/sene.ovh/key.pem";
      tls_certificate_path = "/var/lib/acme/sene.ovh/fullchain.pem";
      max_upload_size = "50M";
      url_preview_enabled = true;
      email = {
         enable_notifs = false;
         smtp_host = "localhost";
         smtp_port = 25;
         require_transport_security = false;
         enable_tls = false;
         notif_from = "matrix@sene.ovh";
         app_name = "Matrix";
         client_base_url = "https://chat.sene.ovh";

         # Uncomment the following to disable automatic subscription to email
         # notifications for new users. Enabled by default.
         #
         #notif_for_new_users: false

         # Configure the time that a validation email will expire after sending.
         # Defaults to 1h.
         #
         #validation_token_lifetime: 15m

         # The web client location to direct users to during an invite. This is passed
         # to the identity server as the org.matrix.web_client_location key. Defaults
         # to unset, giving no guidance to the identity server.
         #
         invite_client_location = "https://chat.sene.ovh";

         subjects = {
           #message_from_person_in_room: "[%(app)s] You have a message on %(app)s from %(person)s in the %(room)s room..."
           #message_from_person: "[%(app)s] You have a message on %(app)s from %(person)s..."
           #messages_from_person: "[%(app)s] You have messages on %(app)s from %(person)s..."
           #messages_in_room: "[%(app)s] You have messages on %(app)s in the %(room)s room..."
           #messages_in_room_and_others: "[%(app)s] You have messages on %(app)s in the %(room)s room and others..."
           #messages_from_person_and_others: "[%(app)s] You have messages on %(app)s from %(person)s and others..."
           #invite_from_person_to_room: "[%(app)s] %(person)s has invited you to join the %(room)s room on %(app)s..."
           #invite_from_person: "[%(app)s] %(person)s has invited you to chat on %(app)s..."
           password_reset = "[%(server_name)s] Password reset";
           email_validation = "[%(server_name)s] Validate your email";
        };
      };
    };
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

  services.signald.enable = true;
  services.mautrix-signal = {
    enable = true;
    settings = {
      homeserver.address = "https://matrix.sene.ovh";
      bridge.permissions = {
        "@vskilet:sene.ovh" = "admin";
      };
    };
  };

  services.nginx.virtualHosts = {
    "chat.sene.ovh" = {
      enableACME = true;
      forceSSL = true;
      serverAliases = [ "riot.sene.ovh" ];
      locations."/" = {
        root = pkgs.element-web.override {
          conf = {
            default_server_config = {
              "m.homeserver" = {
                base_url = "https://matrix.sene.ovh";
                server_name = "matrix.sene.ovh";
              };
              "m.identity_server" = {
                base_url = "https://vector.im";
              };
            };
            brand = "SENE-NET";
            default_theme = "dark";
            defaultCountryCode = "FR";
            integrations_ui_url = "https://dimension.t2bot.io/element";
            integrations_rest_url = "https://dimension.t2bot.io/api/v1/scalar";
            integrations_widgets_urls = ["https://dimension.t2bot.io/widgets"];
            integrations_jitsi_widget_url = "https://dimension.t2bot.io/widgets/jitsi";
          };
        };
      };
    };
    "matrix.sene.ovh" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8008/health";
        extraConfig = ''
          error_page 404 https://sene.ovh/errorpages/50x.html;
        '';
      };
      locations."/_matrix" = {
        proxyPass = "http://127.0.0.1:8008";
        extraConfig = ''
          client_max_body_size 50M;
        '';
      };
      locations."/_synapse/client" = {
        proxyPass = "http://127.0.0.1:8008";
        extraConfig = ''
          client_max_body_size 50M;
        '';
      };
    };
  };
}
