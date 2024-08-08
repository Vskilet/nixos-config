{ pkgs, config, lib, ... }:

{
  users.groups.mautrix-signal.members = [ "matrix-synapse" ];
  services.mautrix-signal = {
    enable = true;
    settings = {
      homeserver.address = config.services.matrix-synapse.settings.public_baseurl;
      appservice = {
        bot.displayname = "Signal Bot";
        database = {
          type = "sqlite3";
          uri = "/var/lib/mautrix-signal/database.db";
        };
        #ephemeral_events = false;
        id = "signal";
      };
      bridge = {
        encryption = {
          allow = true;
          default = true;
          require = false;
        };
        history_sync = {
          request_full_sync = true;
        };
        mute_bridging = false;
        permissions = {
          "@vskilet:sene.ovh" = "admin";
        };
        private_chat_portal_meta = true;
        provisioning = {
          shared_secret = "disable";
        };
      };
    };
  };
}
