{ pkgs, config, lib, ... }:

{
  users.groups.mautrix-whatsapp.members = [ "matrix-synapse" ];
  services.mautrix-gmessages = {
    enable = true;
    settings = {
      homeserver.address = config.services.matrix-synapse.settings.public_baseurl;
      appservice = {
        bot = {
          username = "gmessagesbot";
          displayname = "Google Messages Bot";
        };
        ephemeral_events = true;
        id = "gmessages";
      };
      backfill.enabled = true;
      bridge = {
        bridge_matrix_leave = true;
        command_prefix = "!google";
        private_chat_portal_meta = true;
        mute_only_on_create = false;
        permissions = {
          "*" = "relay";
          "@vskilet:sene.ovh" = "admin";
        };
        relay.enabled = true;
      };
      database = {
        type = "sqlite3-fk-wal";
        uri = "file:/var/lib/mautrix-gmessages/mautrix-gmessages?_txlock=immediate";
      };
      double_puppet = {
        allow_discovery = true;
      };
      encryption = {
        allow = true;
        default = true;
        require = false;
      };
      network = {
        displayname_template = "{{or .FullName .FirstName .PhoneNumber}} (Google)";
        os_name = "mautrix-gmessages";
        url_previews = true;
      };
      provisioning = {
        shared_secret = "disable";
      };
    };
  };
}
