{ pkgs, config, lib, ... }:

{
  services.unifi = {
    enable = true;
    unifiPackage = pkgs.unifi;
    mongodbPackage = pkgs.mongodb-ce;
    openFirewall = true;
  };

  services.nginx.virtualHosts."unifi.sene.ovh" = {
    enableACME = true;
    forceSSL = true;
    locations = {
      "/" = {
        extraConfig = ''
          proxy_pass_header Authorization;
          proxy_pass https://127.0.0.1:8443/;
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-Host $host;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
        '';
      };
      "/wss/" = {
        extraConfig = ''
          proxy_pass https://127.0.0.1:8443;
          proxy_http_version 1.1;
          proxy_buffering off;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection "Upgrade";
          proxy_read_timeout 86400;
          proxy_set_header Host $host;
        '';
      };
    };
    serverAliases = [ "unifi.stech.ovh" ];
  };
}
