{ pkgs, config, lib, ... }:

{
  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      kresus = {
        image = "funkwhale/funkwhale";
        ports = [ "" ];
        volumes = [
          "/var/lib/funkwhale/data:"
          "/var/lib/funkwhale/config:"
        ];
        extraOptions = [ "--env-file=/mnt/secrets/funkwhale.env" "--network=host" ];
      };
    };
  };

  services.postgresql = {
    ensureDatabases = [ "funkwhale" ];
    ensureUsers = [{
      name = "funkwhale";
      ensurePermissions = {
        "DATABASE funkwhale" = "ALL PRIVILEGES";
      };
    }];
  };

  services.nginx.virtualHosts."podcats.sene.ovh" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:9876/";
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
