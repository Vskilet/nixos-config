{ pkgs, config, lib, ... }:

{
  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      peertube = {
        image = "chocobozzz/peertube:v3.2.1-buster";
        ports = [ "1935:1935" "9000:9000" ];
        volumes = [
          "/var/lib/peertube/data:/data"
          "/var/lib/peertube/config:/config"
        ];
        extraOptions = [ "--network=peertube" "--env-file=/mnt/secrets/peertube.env" ];
        dependsOn = [
          "postgres"
          "redis"
        ];
      };
      postgres = {
        image = "postgres:13-alpine";
        volumes = [
          "/var/lib/peertube/db:/var/lib/postgresql/data"
        ];
        extraOptions = [ "--network=peertube" "--env-file=/mnt/secrets/peertube.env" ];
      };
      redis = {
        image = "redis:6-alpine";
        volumes = [
          "/var/lib/peertube/redis:/data"
        ];
        extraOptions = [ "--network=peertube" ];
      };
    };
  };

  systemd.services.init-peertube-network = {
    description = "Create the network bridge for peertube.";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig.Type = "oneshot";
    script = let dockercli = "${config.virtualisation.docker.package}/bin/docker";
             in ''
               check=$(${dockercli} network ls | grep "peertube" || true)
               if [ -z "$check" ]; then
                 ${dockercli} network create peertube
               else
                 echo "peertube network already exists in docker"
               fi
             '';
  };

  services.nginx.virtualHosts."videos.sene.ovh" = {
  	enableACME = true;
    forceSSL = true;
    locations = { "/" = {
      proxyPass = "http://127.0.0.1:9000/";
      extraConfig = ''
        client_max_body_size 5G;
      '';
    }; };
  };

  networking.firewall.allowedTCPPorts = [
    1935 # RTMP
  ];
}
