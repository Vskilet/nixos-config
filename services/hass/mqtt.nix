{ pkgs, config, lib, ... }:

{
  services.mosquitto = {
    enable = true;
    listeners = [
      {
        acl = [ "pattern readwrite #" ];
        omitPasswordAuth = true;
        settings.allow_anonymous = true;
      }
    ];
  };

  services.home-assistant.config = {
    mqtt = null;
  };

  networking.firewall.allowedTCPPorts = [ 1883 ];
}
