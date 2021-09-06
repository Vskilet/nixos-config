{ pkgs, config, lib, ... }:

{
  services.postgresql.enable = true;
  # Try to create database

  users.users.gitea.uid = 998;
  users.groups.gitea.gid = 492;
  services.gitea = {
    enable = true;
    cookieSecure = true;
    httpPort = 30006;
    rootUrl = "https://git.sene.ovh/";
    disableRegistration = true;
    log.level = "Warn";
    database = {
      type = "postgres";
      passwordFile = "/mnt/secrets/gitea_database_passwordFile";
    };
    settings = {
      server = {
        LANDING_PAGE = "explore";
      };
    };
  };

  services.nginx.virtualHosts."git.sene.ovh" = {
    enableACME = true;
    forceSSL = true;
    locations."/".proxyPass = "http://127.0.0.1:${toString(config.services.gitea.httpPort)}";
  };
}
