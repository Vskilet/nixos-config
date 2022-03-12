{ pkgs, config, lib, ... }:

{
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
      frontend = null;
      history = null;
      http = {
        server_host = "::1";
        trusted_proxies = [ "::1" ];
        use_x_forwarded_for = true;
      };
      logbook = null;
      map = null;
      media_player = null;
      mobile_app = null;
      person = null;
      script = null;
      sonos = {
        media_player.hosts = [ "172.16.2.11" "172.16.2.14" ];
      };
      sun = null;
      system_health = null;
      shelly  = null;
      zha = null;
    };
  };

  services.nginx.virtualHosts."home.sene.ovh" = {
    enableACME = true;
    forceSSL   = true;
    extraConfig = ''
      proxy_buffering off;
    '';
    locations."/" = {
      proxyPass = "http://[::1]:${toString(config.services.home-assistant.port)}/";
      proxyWebsockets = true;
    };
  };
}
