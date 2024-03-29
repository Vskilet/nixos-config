{ pkgs, config, lib, ... }:

{
  services.postgresql.enable = true;
  # Try to create database

  services.nextcloud = {
    enable = true;
    hostName = "cloud.sene.ovh";
    https = true;
    package = pkgs.nextcloud28;
    autoUpdateApps.enable = true;
    configureRedis = true;
    config = {
      dbtype = "pgsql";
      dbuser = "nextcloud";
      dbpassFile = "/mnt/secrets/nextcloud_config_dbpassFile";
      dbtableprefix = "oc_";
      adminpassFile = "/mnt/secrets/nextcloud_config_adminpassFile";
      extraTrustedDomains = config.services.nginx.virtualHosts."cloud.sene.ovh".serverAliases;
      defaultPhoneRegion = "FR";
    };
    phpOptions = {
      "opcache.interned_strings_buffer" = "10";
    };
  };
  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      onlyoffice = {
        image = "onlyoffice/documentserver";
        ports = [ "9981:80" ];
        environmentFiles = [ "/mnt/secrets/onlyoffice.env" ];
      };
    };
  };

  services.nginx.virtualHosts = {
    "cloud.sene.ovh" = {
      enableACME = true;
      forceSSL = true;
      serverAliases = [ "cloud.stech.ovh" ];
    };
    "onlyoffice.sene.ovh" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:9981/";
      };
    };
  };
}
