{ pkgs, config, lib, ... }:

{
  users.groups.mautrix-whatsapp.members = [ "matrix-synapse" ];
  services.mautrix-whatsapp = {
    enable = true;
    settings = {
      homeserver.address = config.services.matrix-synapse.settings.public_baseurl;
      appservice = {
        bot = {
          username = "whatsappbot";
          displayname = "WhatsApp Bot";
        };
        ephemeral_events = true;
        id = "whatsapp";
        #TO DELETE when service is backported
        database = lib.mkForce null;
      };
      backfill.enabled = true;
      bridge = {
        bridge_matrix_leave = true;
        command_prefix = "!wa";
        private_chat_portal_meta = true;
        mute_only_on_create = false;
        permissions = {
          "*" = "relay";
          "@vskilet:sene.ovh" = "admin";
        };
        relay.enabled = true;
        #TO DELETE when service is backported
        displayname_template = lib.mkForce null;
        double_puppet_server_map = lib.mkForce null;
        login_shared_secret_map = lib.mkForce null;
        username_template = lib.mkForce null;
      };
      database = {
        type = "sqlite3-fk-wal";
        uri = "file:/var/lib/mautrix-whatsapp/mautrix-whatsapp.db?_txlock=immediate";
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
        displayname_template = "{{or .FullName .PushName}} (WA)";
        os_name = "mautrix-whatsapp";
        url_previews = true;
      };
      provisioning = {
        shared_secret = "disable";
      };
    };
  };
}
