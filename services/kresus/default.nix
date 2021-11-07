{ pkgs, config, lib, ... }:

{
  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      kresus = {
        image = "bnjbvr/kresus";
        ports = [ "9876:9876" ];
        volumes = [
          "/var/lib/kresus/data:/data"
          "/var/lib/kresus/config:/config"
        ];
        extraOptions = [ "--env-file=/mnt/secrets/kresus.env" "--network=host" ];
      };
    };
  };

  services.postgresql = {
    ensureDatabases = [ "kresus" ];
    ensureUsers = [{
      name = "kresus";
      ensurePermissions = {
        "DATABASE kresus" = "ALL PRIVILEGES";
      };
    }];
  };

  services.nginx.virtualHosts."kresus.sene.ovh" = {
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
