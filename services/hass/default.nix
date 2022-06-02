{ pkgs, config, lib, ... }:

let
  meross = builtins.fetchTarball {
    url = "https://github.com/krahabb/meross_lan/archive/refs/tags/v2.5.7.tar.gz";
    sha256 = "1hr161g0gqgv910ra1i5z52r101i544blrnfy99hxfzyzgk76h78";
  };

in {
  systemd.tmpfiles.rules = [
    "C /var/lib/hass/custom_components/meross - - - - ${meross}/custom_components/meross_lan"
    "Z /var/lib/hass/custom_components 700 hass hass - -"
  ];

  services.home-assistant = {
    enable = true;
    config = {
      homeassistant = {
        name = "Home";
        currency = "EUR";
        unit_system = "metric";
        time_zone = "Europe/Paris";
      };
      config = null;
      dhcp = null;
      frontend = null;
      history = null;
      http = {
        server_host = "::1";
        trusted_proxies = [ "::1" ];
        use_x_forwarded_for = true;
      };
      kodi = null;
      logbook = null;
      map = null;
      media_player = null;
      mobile_app = null;
      openweathermap = null;
      #person = [
      #  {
      #    name = test
      #  }
      #];
      script = null;
      sonos = {
        media_player.hosts = [ "172.16.2.11" "172.16.2.14" ];
      };
      sun = null;
      system_health = null;
      shelly  = null;
      weather = null;
      zeroconf = null;
    };
    lovelaceConfig = {
      views = [ {
        title = "Home";
        cards = [
          {
            type = "vertical-stack";
            cards = [ {
              type = "weather-forecast";
              entity = "weather.openweathermap";
            } ];
          }
          {
            type = "vertical-stack";
            cards = [
              {
                type = "button";
                tap_action = {
                  action = "toggle";
                };
                entity = "switch.ivar";
                name = "Ivar";
                icon = "mdi:floor-lamp";
                icon_height = "50px";
              }
              {
                type = "button";
                tap_action = {
                  action = "toggle";
                };
                entity = "switch.halogene";
                name = "Halogène";
                icon = "mdi:floor-lamp-dual";
                icon_height = "50px";
              }
              {
                type = "button";
                tap_action = {
                  action = "toggle";
                };
                entity = "switch.soleil";
                name = "Soleil";
                icon = "mdi:wall-sconce-round";
                icon_height = "50px";
              }
              {
                type = "button";
                tap_action = {
                  action = "toggle";
                };
                entity = "light.smart_light_2104013813353790848148e1e969658d";
                name = "Veilleuse";
                icon = "mdi:lightbulb";
                icon_height = "50px";
              }

            ];
          }
          {
            type = "vertical-stack";
            cards = [
              {
                type = "media-control";
                entity ="media_player.salon";
              }
              {
                type = "media-control";
                entity ="media_player.prunille";
              }
              {
                type = "media-control";
                entity ="media_player.osmc";
              }
            ];
          }
        ];
      } ];
    };
  };

  services.nginx.virtualHosts."home.sene.ovh" = {
    enableACME = true;
    forceSSL   = true;
    extraConfig = ''
      proxy_buffering off;
    '';
    locations."/" = {
      proxyPass = "http://[::1]:${toString(config.services.home-assistant.config.http.server_port)}/";
      proxyWebsockets = true;
    };
  };
}
