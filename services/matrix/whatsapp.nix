{ pkgs, config, lib, ... }:

{
  users.groups.mautrix-whatsapp.members = [ "matrix-synapse" ];
  services.mautrix-whatsapp = {
    enable = true;
    settings = {
      homeserver.address = config.services.matrix-synapse.settings.public_baseurl;
      appservice = {
        bot.displayname = "WhatsApp Bot";
        database = {
          type = "sqlite3-fk-wal";
          uri = "file:/var/lib/mautrix-whatsapp/mautrix-whatsapp.db?_txlock=immediate";
        };
        ephemeral_events = true;
        id = "whatsapp";
      };
      backfill.enabled = true;
      bridge = {
        bridge_matrix_leave = true;
        displayname_template = "{{or .FullName .PushName}} (WA)";
        double_puppet_allow_discovery = true;
        encryption = {
          allow = true;
          default = true;
          require = false;
        };
        history_sync = {
          backfill = true;
        };
        mute_bridging = true;
        parallel_member_sync = true;
        private_chat_portal_meta = "always";
        url_previews = true;
        user_avatar_sync = true;
        mute_only_on_create = false;
        permissions = {
          "@vskilet:sene.ovh" = "admin";
        };
        provisioning = {
          shared_secret = "disable";
        };
      };
    };
  };
}
