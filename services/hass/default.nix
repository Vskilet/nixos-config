{ pkgs, config, lib, ... }:

let
  meross = builtins.fetchTarball {
    url = "https://github.com/krahabb/meross_lan/archive/refs/tags/v4.2.0.tar.gz";
    sha256 = "1rjh2izv7hm1dnxzbd98xh7r2gx8cwssad0imzw9x8flzmvbsx2c";
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
        country = "FR";
        time_zone = "Europe/Paris";
        latitude = "!secret zone_home_latitude";
        longitude = "!secret zone_home_longitude";
        elevation = "150";
      };
      automation = [
        {
          id = "victor_leave_work";
          alias = "Victor leave Work";
          use_blueprint = {
            path = "homeassistant/notify_leaving_zone.yaml";
            input = {
              person_entity = "person.victor_sene";
              zone_entity = "zone.work";
              notify_device = "05119a513c81136a19eec038d5d86e88";
            };
          };
        }
      ];
      config = {};
      counter = {};
      dhcp = {};
      energy = {};
      frontend = {};
      history = {};
      http = {
        server_host = "::1";
        trusted_proxies = [ "::1" ];
        use_x_forwarded_for = true;
      };
      input_boolean = {};
      input_button = {};
      input_datetime = {};
      input_number = {};
      input_select = {};
      input_text = {};
      kodi = {};
      logbook = {};
      map = {};
      media_player = {};
      mobile_app = {};
      my = {};
      openweathermap = {};
      #person = [
      #  {
      #    name = test
      #  }
      #];
      script = {};
      shelly  = {};
      sonos = {
        media_player.hosts = [ "172.16.2.11" "172.16.2.14" ];
      };
      ssdp = {};
      sun = {};
      system_health = {};
      tag = {};
      weather = {};
      webhook = {};
      zeroconf = {};
      zone = [
        {
          name = "Home";
          latitude = "!secret zone_home_latitude";
          longitude = "!secret zone_home_longitude";
          radius = "40";
          icon = "mdi:home";
        }
        {
          name = "Work";
          latitude = "!secret zone_work_latitude";
          longitude = "!secret zone_work_longitude";
          radius = "121";
          icon = "mdi:server";
        }
      ];
    };
    lovelaceConfig = {
      views = [ {
        title = "Home";
        cards = [
          {
            type = "vertical-stack";
            cards = [
              {
                type = "weather-forecast";
                entity = "weather.openweathermap";
              }
              {
                type = "history-graph";
                entities = [
                  {
                    entity = "person.victor_sene";
                  }
                  {
                    entity = "person.constance";
                  }
                ];
                refresh_interval = "0";
                hours_to_show = "15";
              }
            ];
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

  networking.firewall.allowedTCPPorts = [
    1400  # Sonos
  ];
}
