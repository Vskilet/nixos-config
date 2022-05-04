{ pkgs, config, lib, ... }:

{
  #services.wordpress = {
  #  webserver = "nginx";
  #  sites."cb.sene.ovh" = {
  #    database = {
  #      name = "wp_cb";
  #      tablePrefix = "wp_cb_";
  #      createLocally = true;
  #    };
  #    virtualHost = {
  #      adminAddr = "victor@sene.ovh";
  #      serverAliases = ["cb.sene.ovh" "www.cb.sene.ovh"];
  #    };
  #  };
  #};

  #services.nginx.virtualHosts."cb.sene.ovh" = {
  #  enableACME = true;
  #  forceSSL   = true;
  #};

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      cb-wp = {
        image = "wordpress:5.9.3";
        ports = [ "10002:80" ];
        volumes = [
          "/var/www/cb.sene.ovh/wordpress:/var/www/html"
        ];
        extraOptions = [ "--network=cb" "--env-file=/mnt/secrets/cb.env" ];
        dependsOn = [
          "cb-db"
        ];
      };
      cb-db = {
        image = "mariadb:10.7.3";
        volumes = [
          "/var/www/cb.sene.ovh/db:/var/lib/mysql"
        ];
        extraOptions = [ "--network=cb" "--env-file=/mnt/secrets/cb.env" ];
      };
    };
  };

  systemd.services.init-cb-network = {
    description = "Create the network bridge for CB WordPress.";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig.Type = "oneshot";
    script = let dockercli = "${config.virtualisation.docker.package}/bin/docker";
             in ''
               check=$(${dockercli} network ls | grep "cb" || true)
               if [ -z "$check" ]; then
                 ${dockercli} network create cb
               else
                 echo "CB network already exists in docker"
               fi
             '';
  };


  services.nginx.virtualHosts."cb.sene.ovh" = {
  	enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:10002/";
    };
  };

}
