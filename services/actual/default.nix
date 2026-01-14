{ pkgs, config, lib, ... }:

{
  services.actual = {
    enable = true;
    settings = {
      port = 10004;
    };
  };

  services.nginx.virtualHosts."actual.sene.ovh" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString(config.services.actual.settings.port)}/";
      extraConfig = ''
        auth_request_set $cookie $upstream_http_set_cookie;
        add_header Set-Cookie $cookie;
      '';
    };
    extraConfig = ''
      include ${toString(config.environment.etc."nginx-sso_auth.inc".source)};
    '';
  };
}
