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
    enable_registration = false;
    server_name = "sene.ovh";
    public_baseurl = "https://matrix.sene.ovh";
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
    extraConfig = ''
      email:
         enable_notifs: false
         smtp_host: "localhost"
         smtp_port: 25
         require_transport_security: false
         enable_tls: false
         notif_from: "matrix@sene.ovh"
         app_name: Matrix
         client_base_url: "https://chat.sene.ovh"

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
         invite_client_location: https://chat.sene.ovh

         subjects:
           #message_from_person_in_room: "[%(app)s] You have a message on %(app)s from %(person)s in the %(room)s room..."
           #message_from_person: "[%(app)s] You have a message on %(app)s from %(person)s..."
           #messages_from_person: "[%(app)s] You have messages on %(app)s from %(person)s..."
           #messages_in_room: "[%(app)s] You have messages on %(app)s in the %(room)s room..."
           #messages_in_room_and_others: "[%(app)s] You have messages on %(app)s in the %(room)s room and others..."
           #messages_from_person_and_others: "[%(app)s] You have messages on %(app)s from %(person)s and others..."
           #invite_from_person_to_room: "[%(app)s] %(person)s has invited you to join the %(room)s room on %(app)s..."
           #invite_from_person: "[%(app)s] %(person)s has invited you to chat on %(app)s..."
           password_reset: "[%(server_name)s] Password reset"
           email_validation: "[%(server_name)s] Validate your email"
    '';
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
