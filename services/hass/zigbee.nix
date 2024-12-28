{ pkgs, config, lib, ... }:

{
  services.zigbee2mqtt = {
    enable = true;
    settings = {
      mqtt = {
        server = "mqtt://127.0.0.1:1883";
        #server = "mqtt://${(head config.services.mosquitto.listeners).address}:${toString (head config.services.mosquitto.listeners).port}";
      };
      frontend = {
        port = 8099;
        host = "127.0.0.1";
        url = "https://zigbee.sene.ovh";
      };
      groups = {
        "101" = {
          friendly_name = "salon";
          devices = [
            #"0x94deb8fffe760f3d"
          ];
        };
        "102" = {
          friendly_name = "cuisine";
          devices = [
            #"0x003c84fffe6d9ee6"
          ];
        };
      };
    };
  };

  services.nginx.virtualHosts."zigbee.sene.ovh" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://${config.services.zigbee2mqtt.settings.frontend.host}:${toString config.services.zigbee2mqtt.settings.frontend.port}/";
      proxyWebsockets = true;
      extraConfig = ''
        auth_request_set $cookie $upstream_http_set_cookie;
        auth_request_set $username $upstream_http_x_username;
        proxy_set_header X-WEBAUTH-USER $username;
        add_header Set-Cookie $cookie;
      '';
    };
    extraConfig = ''
      include ${toString(config.environment.etc."nginx-sso_auth.inc".source)};
    '';
  };
}
