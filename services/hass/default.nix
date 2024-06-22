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

  imports = [
    ./mqtt.nix
  ];

  services.home-assistant = {
    enable = true;
    extraComponents = [
      "esphome"
      "met"
      "overkiz"
      "radio_browser"
    ];
    config = {
      default_config = {};
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
        {
          id = "good_bye";
          alias = "Good bye";
          mode = "single";
          trigger = [
            {
              platform = "zone";
              entity_id = "person.constance";
              zone = "zone.home";
              event = "leave";
            }
            {
              platform = "zone";
              entity_id = "person.victor_sene";
              zone = "zone.home";
              event = "leave";
            }
          ];
          action = [
            {
              service = "scene.turn_on";
              target.entity_id = "scene.night";
            }
          ];
        }
        {
          id = "sweat_home";
          alias = "Welome Home";
          mode = "single";
          trigger = [
            {
              platform = "zone";
              entity_id = "person.constance";
              zone = "zone.home";
              event = "enter";
            }
            {
              platform = "zone";
              entity_id = "person.victor_sene";
              zone = "zone.home";
              event = "enter";
            }
          ];
          condition = [
            {
              condition = "sun";
              after = "sunset";
              before = "sunrise";
            }
          ];
          action = [
            {
              service = "scene.turn_on";
              target.entity_id = "scene.welcome";
            }
          ];
        }
        {
          id = "midnight_sleep";
          alias = "Go Dodo";
          mode = "single";
          trigger = [
            {
              platform = "time";
              at = "00:00:00";
            }
          ];
          action = [
            {
              service = "scene.turn_on";
              target.entity_id = "scene.night";
            }
            {
              service = "light.turn_off";
              target.entity_id = "light.smart_light_2104013813353790848148e1e969658d";
            }
          ];
        }
      ];
      http = {
        server_host = "::1";
        trusted_proxies = [ "::1" ];
        use_x_forwarded_for = true;
      };
      kodi = {};
      media_player = [
        {
          platform = "kodi";
          name = "kodi";
          host = "172.16.2.19";
        }
      ];
      mobile_app = {};
      openweathermap = {};
      scene = [
        {
          name = "Welcome";
          icon = "mdi:home";
          entities = {
            "switch.soleil" = {
              state = "on";
            };
            "switch.ivar" = {
              state = "on";
            };
            "switch.cuisine" = {
              state = "on";
            };
            "switch.halogene" = {
              state = "on";
            };
          };
        }
        {
          name = "Night";
          icon = "mdi:weather-night";
          entities = {
            "switch.soleil" = {
              state = "off";
            };
            "switch.ivar" = {
              state = "off";
            };
            "switch.cuisine" = {
              state = "off";
            };
            "switch.halogene" = {
              state = "off";
            };
            "light.smart_light_2104013813353790848148e1e969658d" = {
              state = "off";
            };
            "media_player.prunille" = {
              state = "off";
            };
            "media_player.salon" = {
              state = "off";
            };
          };
        }
      ];
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
