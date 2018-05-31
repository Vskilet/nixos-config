{ config, lib, pkgs, ... }:

with lib;

let
  domain = "sene.ovh";
  riot_port = 30001;
  wedding_port = 30002;
  pgmanage_port = 30003;
  vilodec_port = 30004;
  roundcube_port = 30005;
in
{
  imports = [
    ./services/nextcloud.nix
    ./services/mailserver.nix
    ./services/haproxy-acme.nix
    ./services/roundcube.nix
  ];

  services.haproxy-acme.enable = true;
  services.haproxy-acme.domain = domain;
  services.haproxy-acme.services = {
    "grafana.${domain}" = { ip = "127.0.0.1"; port = 3000; auth = false; };
    "stream.${domain}" = { ip = "127.0.0.1"; port = 8096; auth = false; };
    "seed.${domain}" = { ip = "127.0.0.1"; port = 9091; auth = true; };
    "cloud.${domain}" = { ip = "127.0.0.1"; port = 8441; auth = false; };
    "searx.${domain}" = { ip = "127.0.0.1"; port = 8888; auth = false; };
    "shell.${domain}" = { ip = "127.0.0.1"; port = 4200; auth = true; };
    "riot.${domain}" = { ip = "127.0.0.1"; port = riot_port; auth = false; };
    "matrix.${domain}" = { ip = "127.0.0.1"; port = 8008; auth = false; };
    "sync.${domain}" = { ip = "127.0.0.1"; port = 5000; auth = false; };
    "constanceetvictor.fr" = { ip = "127.0.0.1"; port = wedding_port; auth = false; };
    "pgmanage.${domain}" = { ip = "127.0.0.1"; port = pgmanage_port; auth = true; };
    "vilodec.fr" = { ip = "127.0.0.1"; port = vilodec_port; auth = false; };
  };

  services.nginx.enable = true;
  services.nginx.virtualHosts = {
    "riot" = {
      listen = [ { addr = "127.0.0.1"; port = riot_port; } ];
      locations = { "/" = { root = pkgs.riot-web; }; };
    };
    "wedding" = {
      listen = [ { addr = "127.0.0.1"; port = wedding_port; } ];
      locations = { "/" = { root = "/var/www/wedding"; }; };
    };
    "vilodec" = {
      listen = [ { addr = "127.0.0.1"; port = vilodec_port; } ];
      locations = { "/" = { 
        root = "/var/www/vilodec";
	index = "index.php";
        extraConfig = ''
          location ~* \.php$ {
            fastcgi_split_path_info ^(.+\.php)(/.+)$;
            fastcgi_pass unix:/run/phpfpm/web;
            include ${pkgs.nginx}/conf/fastcgi_params;
            include ${pkgs.nginx}/conf/fastcgi.conf;
          }
        '';
      }; };
    };
  };
  
  services.phpfpm.poolConfigs.web = ''
    listen = /run/phpfpm/web
    listen.owner = nginx
    listen.group = nginx
    listen.mode = 0660
    user = nginx
    pm = dynamic
    pm.max_children = 75
    pm.start_servers = 2
    pm.min_spare_servers = 1
    pm.max_spare_servers = 20
    pm.max_requests = 500
    php_admin_value[error_log] = 'stderr'
    php_admin_flag[log_errors] = on
    catch_workers_output = yes
  '';
  
  services.influxdb.enable = true;
  services.influxdb.dataDir = "/var/db/influxdb";

  services.telegraf.enable = true;
  services.telegraf.extraConfig = {
    inputs = {
      zfs = { poolMetrics = true; };
      net = { interfaces = [ "enp2s0" ]; };
      netstat = {};
      cpu = { totalcpu = true; };
      kernel = {};
      mem = {};
      swap = {};
      processes = {};
      system = {};
      disk = {};
    };
    outputs = {
      influxdb = { database = "telegraf"; urls = [ "http://localhost:8086" ]; };
    };
  };
  
  services.grafana.enable = true;
  services.grafana.addr = "127.0.0.1";
  services.grafana.dataDir = "/var/lib/grafana";

  services.emby.enable = true;
  services.emby.dataDir = "/var/lib/emby/ProgramData-Server";

  services.transmission.enable = true;
  services.transmission.home = "/var/lib/transmission";
  services.transmission.settings = {
    rpc-bind-address = "127.0.0.1";
    rpc-host-whitelist = "*";
    rpc-whitelist-enabled = false;
  };
  
  services.nextcloud.enable = true;  
  services.nextcloud.vhosts = [ "cloud.${domain}" ];
  
  services.postgresql.enable = true;
  services.pgmanage.enable = true;
  services.pgmanage.port = pgmanage_port;
  services.pgmanage.connections = {
    localhost = "hostaddr=127.0.0.1 port=5432 dbname=postgres";
  };

  services.mysql.enable = true;
  services.mysql.package = pkgs.mysql;

  services.searx.enable = true;
  
  services.mailserver.enable = true;
  services.mailserver.domain = domain;

  services.roundcube.enable = true;
  services.roundcube.port = roundcube_port;
  services.roundcube.domain = "webmail.${domain}";

  services.shellinabox.enable = true;
  services.shellinabox.extraOptions = [ "--css ${./users/white-on-black.css}" ];
  
  services.matrix-synapse = {
    enable = true;
    enable_registration = true;
    server_name = "${domain}";
    listeners = [
      { # federation
        bind_address = "";
        port = 8448;
        resources = [
          { compress = true; names = [ "client" "webclient" ]; }
          { compress = false; names = [ "federation" ]; }
        ];
        tls = true;
        type = "http";
        x_forwarded = false;
      }
      { # client
        bind_address = "127.0.0.1";
        port = 8008;
        resources = [
          { compress = true; names = [ "client" "webclient" ]; }
        ];
        tls = false;
        type = "http";
        x_forwarded = true;
      }
    ];
    database_type = "psycopg2";
    database_args = {
      database = "matrix-synapse";
    };
    extraConfig = ''
      max_upload_size: "100M"
    '';
  };
  
  networking.firewall.allowedTCPPorts = [
    51413 # Transmission
    8448 # Matrix Federation
  ];
  networking.firewall.allowedUDPPorts = [
    51413 # Transmission
  ];
}
