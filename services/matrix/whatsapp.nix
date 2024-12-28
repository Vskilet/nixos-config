{ pkgs, config, lib, ... }:

{
  users.groups.mautrix-whatsapp.members = [ "matrix-synapse" ];
  services.mautrix-whatsapp = {
    enable = true;
    settings = {
      homeserver.address = config.services.matrix-synapse.settings.public_baseurl;
      appservice = {
        bot.displayname = "WhatsApp Bot";
        ephemeral_events = true;
        id = "whatsapp";
      };
      backfill.enabled = true;
      bridge = {
        mute_only_on_create = false;
        permissions = {
          "@vskilet:sene.ovh" = "admin";
        };
        private_chat_portal_meta = true;
      };
      database = {
        type = "sqlite3";
        uri = "file:/var/lib/mautrix-whatsapp/mautrix-whatsapp.db?_txlock=immediate";
      };
      double_puppet = {
        servers = {};
        secrets = {};
      };
      encryption = {
        allow = true;
        default = false;
        require = false;
      };
      provisioning = {
        shared_secret = "disable";
      };
    };
  };
}
