{ config, lib, pkgs, ... }:

with lib;

let
  domain = "sene.ovh";
  riot_port = 30001;
  wedding_port = 30002;
  pgmanage_port = 30003;
  vilodec_port = 30004;
  roundcube_port = 30005;
  gitea_port = 30006;
  office_port = 30007;
in
{
  imports = [
    ../../services/mailserver.nix
    ../../services/haproxy-acme.nix
    ../../services/roundcube.nix
  ];

  services.mailserver.enable = true;
  services.mailserver.domain = domain;

  services.haproxy-acme.enable = true;
  services.haproxy-acme.domain = domain;
  services.haproxy-acme.services = {
    "grafana.${domain}" = { ip = "127.0.0.1"; port = 3000; auth = true; };
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
    "vilodec.${domain}" = { ip = "127.0.0.1"; port = vilodec_port; auth = false; };
    "git.${domain}" = { ip = "127.0.0.1"; port = gitea_port; auth = false; };
    "office.${domain}" = { ip = "127.0.0.1"; port = office_port; auth = false; };
    "roundcube.${domain}" = { ip = "127.0.0.1"; port = roundcube_port; auth = false; };
    "jackett.${domain}" = { ip = "127.0.0.1"; port = 9117; auth = true; };
    "sonarr.${domain}" = { ip = "127.0.0.1"; port = 8989; auth = true; extraAcls = "acl API path_beg /api\n"; aclBool = "!AUTH_OK !API"; };
    "radarr.${domain}" = { ip = "127.0.0.1"; port = 7878; auth = true; extraAcls = "acl API path_beg /api\n"; aclBool = "!AUTH_OK !API"; };
  };
 
  services.roundcube.enable = true;
  services.roundcube.listenAddress = "127.0.0.1";
  services.roundcube.listenPort = roundcube_port;
  services.roundcube.subDomain = "roundcube";
  services.roundcube.extraConfig = lib.fileContents ../../configuration/config.inc.php;

  services.nextcloud = {
    enable = true;
    hostName = "cloud.${domain}";
    https = true;
    nginx.enable = true;
    poolConfig = ''
      pm = dynamic
      pm.max_children = 75
      pm.start_servers = 10
      pm.min_spare_servers = 5
      pm.max_spare_servers = 20
      pm.max_requests = 500
    '';
    config = {
      dbtype = "pgsql";
      dbuser = "nextcloud";
      dbpass = "nextcloud";
      dbtableprefix = "oc_";
      adminpass = "nextlcoud";
    };
  };

  services.searx.enable = true;
  
  services.shellinabox.enable = true;
  services.shellinabox.extraOptions = [ "--css ${../../configuration/white-on-black.css}" ];

  services.gitea = {
    enable = true;
    httpPort = gitea_port;
    rootUrl = "https://git.${domain}/";
    database = {   
      type = "postgres";
      passwordFile = "/mnt/secrets/gitea-db";
    };
  };

  services.emby.enable = true;
  services.emby.dataDir = "/var/lib/emby/ProgramData-Server";
  services.sonarr.enable = true;
  services.radarr.enable = true;
  services.jackett.enable = true;

  services.transmission = {
    enable = true;
    home = "/var/lib/transmission";
    settings = {
      download-dir = "/mnt/medias/downloads/";
      incomplete-dir = "/mnt/medias/downloads/.incomplete";
      incomplete-dir-enabled = true;
      rpc-bind-address = "127.0.0.1";
      rpc-host-whitelist = "*";
      rpc-whitelist-enabled = false;
    };
  };

  services.nginx = {
    enable = true;
    virtualHosts = {
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
      "cloud.${domain}" = {
        listen = [ { addr = "127.0.0.1"; port = 8441; } ];
      };  
      "office" = {
        listen = [ { addr = "127.0.0.1"; port = office_port; } ];
        extraConfig = ''
          # static files
          location ^~ /loleaflet {
              proxy_pass https://localhost:9980;
              proxy_set_header Host $http_host;
          }

          # WOPI discovery URL
          location ^~ /hosting/discovery {
              proxy_pass https://localhost:9980;
              proxy_set_header Host $http_host;
          }

          # main websocket
          location ~ ^/lool/(.*)/ws$ {
              proxy_pass https://localhost:9980;
              proxy_set_header Upgrade $http_upgrade;
              proxy_set_header Connection "Upgrade";
              proxy_set_header Host $http_host;
              proxy_read_timeout 36000s;
          }

          # download, presentation and image upload
          location ~ ^/lool {
              proxy_pass https://localhost:9980;
              proxy_set_header Host $http_host;
          }

          # Admin Console websocket
          location ^~ /lool/adminws {
              proxy_pass https://localhost:9980;
              proxy_set_header Upgrade $http_upgrade;
              proxy_set_header Connection "Upgrade";
              proxy_set_header Host $http_host;
              proxy_read_timeout 36000s;
          }
        '';
      };
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

  services.postgresql.enable = true;
  services.pgmanage.enable = true;
  services.pgmanage.port = pgmanage_port;
  services.pgmanage.connections = {
    localhost = "hostaddr=127.0.0.1 port=5432 dbname=postgres";
  };

  services.mysql.enable = true;
  services.mysql.package = pkgs.mysql;
  
  services.influxdb.enable = true;
  services.influxdb.dataDir = "/var/db/influxdb";

  services.telegraf.enable = true;
  systemd.services.telegraf.path = [ pkgs.lm_sensors ];
  security.sudo.extraRules = [
    { commands = [ { command = "${pkgs.smartmontools}/bin/smartctl"; options = [ "NOPASSWD" ]; } ]; users = [ "telegraf" ]; }
  ];
  services.telegraf.extraConfig = {
    inputs = {
      zfs = { poolMetrics = true; };
      net = { interfaces = [ "enp2s0" ]; };
      netstat = {};
      cpu = { totalcpu = true; };
      sensors = {};
      kernel = {};
      mem = {};
      swap = {};
      processes = {};
      system = {};
      disk = {};
      smart = {
        path = "${pkgs.writeShellScriptBin "smartctl" "/run/wrappers/bin/sudo ${pkgs.smartmontools}/bin/smartctl $@"}/bin/smartctl";
      };
    };
    outputs = {
      influxdb = { database = "telegraf"; urls = [ "http://localhost:8086" ]; };
    };
  };
  
  services.grafana = {
    enable = true;
    addr = "127.0.0.1";
    dataDir = "/var/lib/grafana";
    extraOptions = {
      SERVER_ROOT_URL = "https://grafana.${domain}";
      SMTP_ENABLED = "true";
      SMTP_FROM_ADDRESS = "grafana@${domain}";
      SMTP_SKIP_VERIFY = "true";
      AUTH_DISABLE_LOGIN_FORM = "true";
      AUTH_DISABLE_SIGNOUT_MENU = "true";
      AUTH_ANONYMOUS_ENABLED = "true";
      AUTH_ANONYMOUS_ORG_NAME = "SENE-NET";
      AUTH_ANONYMOUS_ORG_ROLE = "Admin";
      AUTH_BASIC_ENABLED = "false";
    };
  };

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
    logConfig = ''
      version: 1

      formatters:
          journal_fmt:
              format: '%(name)s: [%(request)s] %(message)s'

      filters:
          context:
              (): synapse.util.logcontext.LoggingContextFilter
              request: ""

      handlers:
          journal:
              class: systemd.journal.JournalHandler
              formatter: journal_fmt
              filters: [context]
              SYSLOG_IDENTIFIER: synapse

      root:
          level: WARNING
          handlers: [journal]

      disable_existing_loggers: False
    '';
  };
  systemd.services.matrix-synapse = {
    serviceConfig = {
      MemoryHigh = "3G";
      MemoryMax = "5G";
    };
  };

  services.smartd = {
    enable = true;
    defaults.monitored = "-a -o on -s (S/../.././03|L/../../7/04)";
    notifications.mail = {
      enable = true;
      recipient = "victor@sene.ovh";
    };
  };
  
  services.fail2ban.enable = true;

  services.borgbackup.jobs = {
    senback01 = {
      paths = [
        "/var/certs"
        "/var/dkim"
        "/var/lib/gitea"
        "/var/lib/grafana"
        "/var/lib/matrix-synapse"
        "/var/lib/nextcloud/"
        "/var/lib/.zfs/snapshot/borgsnap/postgresql"
        "/var/sieve"
        "/var/vmail"
      ];
      repo = "/mnt/backups/borg";
      encryption = {
        mode = "repokey-blake2";
        passCommand = "cat /mnt/secrets/borgbackup_senback01_encryption_pass";
      };
      startAt = "weekly";
      prune.keep = {
        within = "1d";
        weekly = 4;
        monthly = 6;
      };
      preHook = "${pkgs.zfs}/bin/zfs snapshot senpool01/var/lib@borgsnap";
      postHook = ''
        ${pkgs.zfs}/bin/zfs destroy senpool01/var/lib@borgsnap
        if [[ $exitStatus == 0 ]]; then
          ${pkgs.rclone}/bin/rclone --config /mnt/secrets/rclone_senback01.conf sync -v $BORG_REPO ovh_backup:senback01
        fi
      '';
    };
  };

  networking.firewall.allowedTCPPorts = [
    51413 # Transmission
    8448 # Matrix Federation
  ];
  networking.firewall.allowedUDPPorts = [
    51413 # Transmission
  ];
}
