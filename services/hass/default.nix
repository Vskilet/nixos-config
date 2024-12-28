{ pkgs, config, lib, ... }:

let
  meross = builtins.fetchTarball {
    url = "https://github.com/krahabb/meross_lan/archive/refs/tags/v5.4.1.tar.gz";
    sha256 = "1ppvgpqj2wvrha8n87c6dnwp2fqa468zlc4qyi053fqg4yrgxs91";
  };

in {
  systemd.tmpfiles.rules = [
    "C ${config.services.home-assistant.configDir}/custom_components/meross - - - - ${meross}/custom_components/meross_lan"
    "Z ${config.services.home-assistant.configDir}/custom_components 700 hass hass - -"
    "f ${config.services.home-assistant.configDir}/automations.yaml 0600 hass hass"
    "f ${config.services.home-assistant.configDir}/scenes.yaml 0600 hass hass"
    "f ${config.services.home-assistant.configDir}/scripts.yaml 0600 hass hass"
  ];

  imports = [
    ./mqtt.nix
    #./zigbee.nix
  ];

  services.home-assistant = {
    enable = true;
    extraComponents = [
      "esphome"
      "kodi"
      "met"
      "openweathermap"
      "overkiz"
      "radio_browser"
    ];
    extraPackages = python3Packages: with python3Packages; [
      isal              # warning from logs without it
      psycopg2          # for postgresql support
      uiprotect         # remove warning in discovery logs
      unifi-ap          # remove warning in discovery logs
      unifi-discovery   # remove warning in discovery logs
      zlib-ng           # warning from logs without it
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
              notify_device = "195e7bec7367ad09e14685fdb9432b94";
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
          alias = "Welcome Home";
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
          ];
        }
      ];
      "automation ui" = "!include automations.yaml";
      http = {
        server_host = "::1";
        trusted_proxies = [ "::1" ];
        use_x_forwarded_for = true;
      };
      mobile_app = {};
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
            "media_player.prunille" = {
              state = "paused";
            };
            "media_player.salon" = {
              state = "paused";
            };
          };
        }
      ];
      "scene ui" = "!include scenes.yaml";
      script = {};
      "script ui" = "!include scripts.yaml";
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
