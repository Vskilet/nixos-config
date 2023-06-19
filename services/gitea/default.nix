{ pkgs, config, lib, ... }:

{
  services.postgresql.enable = true;
  # Try to create database

  users.users.gitea.uid = 998;
  users.groups.gitea.gid = 492;
  services.gitea = {
    enable = true;
    database = {
      type = "postgres";
      passwordFile = "/mnt/secrets/gitea_database_passwordFile";
    };
    settings = {
      log.LEVEL = "Warn";
      service.DISABLE_REGISTRATION = true;
      session.COOKIE_SECURE = true;
      server = {
        HTTP_PORT = 30006;
        LANDING_PAGE = "explore";
        ROOT_URL = "https://git.sene.ovh/";
      };
    };
  };

  services.nginx.virtualHosts."git.sene.ovh" = {
    enableACME = true;
    forceSSL = true;
    locations."/".proxyPass = "http://127.0.0.1:${toString(config.services.gitea.settings.server.HTTP_PORT)}";
  };
}
