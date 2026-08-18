{ pkgs, config, lib, ... }:

{
  services.postgresql = {
    enable = true;
    ensureDatabases = [ "vaultwarden" ];
    ensureUsers = [{
      name = "vaultwarden";
      ensureDBOwnership = true;
    }];
  };

  services.vaultwarden = {
    enable = true;
    dbBackend = "postgresql";
    config = {
      DATABASE_URL = "postgresql://vaultwarden@/vaultwarden";
      DOMAIN = "https://bitwarden.sene.ovh";
      ENABLE_WEBSOCKET = true;
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8222;
      SIGNUPS_DOMAINS_WHITELIST = "sene.ovh";
      SIGNUPS_VERIFY = true;
      SMTP_FROM = "bitwarden@sene.ovh";
      SMTP_FROM_NAME = "sene.ovh - Bitwarden";
      SMTP_HOST = "127.0.0.1";
      SMTP_PORT = 25;
      SMTP_SECURITY = "off";
    };
  };

  services.nginx.virtualHosts."bitwarden.sene.ovh" = {
    enableACME = true;
    forceSSL = true;
    locations = {
      "/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.vaultwarden.config.ROCKET_PORT}";
        proxyWebsockets = true;
      };
    };
  };
}
