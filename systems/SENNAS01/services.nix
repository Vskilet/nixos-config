{ config, lib, pkgs, ... }:

with lib;

let
  domain = "sene.ovh";

  jellyfin_backend = ''
    http-request set-header X-Forwarded-Port %[dst_port]
    http-request add-header X-Forwarded-Proto https if { ssl_fc }
  '';

  nginxGetFirstLocalPort = vh: (findFirst (x: x.addr == "127.0.0.1") (throw "No local port found") config.services.nginx.virtualHosts.${vh}.listen).port;
in
{
  imports = [
    ../../services/mailserver.nix
    ../../services/haproxy-acme.nix
    ../../services/mautrix-whatsapp.nix
  ];

  ####################################
  ##          WEB services          ##
  ####################################
  services.haproxy-acme.enable = true;
  services.haproxy-acme.domain = domain;
  services.haproxy-acme.services = {
    "roundcube.${domain}" = { ip = "127.0.0.1"; port = nginxGetFirstLocalPort "${config.services.roundcube.hostName}"; auth = false; };
    "cloud.${domain}" = { ip = "127.0.0.1"; port = 8441; auth = false; };
    "office.${domain}" = { ip = "127.0.0.1"; port = nginxGetFirstLocalPort "office"; auth = false; };
    "searx.${domain}" = { ip = "127.0.0.1"; port = 8888; auth = false; };
    "git.${domain}" = { ip = "127.0.0.1"; port = config.services.gitea.httpPort; auth = false; };
    "shell.${domain}" = { ip = "127.0.0.1"; port = 4200; auth = true; };
    "stream.${domain}" = { ip = "127.0.0.1"; port = 8096; auth = false; extraBackend = "${jellyfin_backend}"; };
    "jackett.${domain}" = { ip = "127.0.0.1"; port = 9117; auth = true; };
    "sonarr.${domain}" = { ip = "127.0.0.1"; port = 8989; auth = true; extraAcls = "acl API path_beg /api\n"; aclBool = "!AUTH_OK !API"; };
    "radarr.${domain}" = { ip = "127.0.0.1"; port = 7878; auth = true; extraAcls = "acl API path_beg /api\n"; aclBool = "!AUTH_OK !API"; };
    "seed.${domain}" = { ip = "127.0.0.1"; port = 9091; auth = true; };
    "riot.${domain}" = { ip = "127.0.0.1"; port = nginxGetFirstLocalPort "riot"; auth = false; };
    "matrix.${domain}" = { ip = "127.0.0.1"; port = 8008; auth = false; };
    "wedding.${domain}" = { ip = "127.0.0.1"; port = nginxGetFirstLocalPort "wedding"; auth = false; };
    "vilodec.${domain}" = { ip = "127.0.0.1"; port = nginxGetFirstLocalPort "vilodec"; auth = false; };
    "apc.${domain}" = { ip = "127.0.0.1"; port = nginxGetFirstLocalPort "apc.${domain}"; auth = false; };
    "pgmanage.${domain}" = { ip = "127.0.0.1"; port = config.services.pgmanage.port; auth = true; };
    "grafana.${domain}" = { ip = "127.0.0.1"; port = 3000; auth = true; };
    "videos.${domain}" = { ip = "127.0.0.1"; port = 9000; auth = false; };

    "external.vilodec.fr" = { ip = "127.0.0.1"; port = 4200; auth = true; };
  };

  services.roundcube = {
    enable = true;
    hostName = "roundcube.${domain}";
    database = {
      username = "roundcube";
      host = "localhost";
      dbname = "roundcube";
    };
    plugins = ["archive" "attachment_reminder" "autologon" "emoticons" "filesystem_attachments" "help" "identicon" "identity_select" "jqueryui" "managesieve" "show_additional_headers" "subscriptions_option" "virtuser_file" "zipdownload"];
    extraConfig = lib.fileContents ../../misc/config.inc.php;
  };

  services.nextcloud = {
    enable = true;
    hostName = "cloud.${domain}";
    https = true;
    package = pkgs.nextcloud18;
    nginx.enable = true;
    poolSettings = {
      "pm" = "dynamic";
      "pm.max_children" = "75";
      "pm.start_servers" = "10";
      "pm.min_spare_servers" = "5";
      "pm.max_spare_servers" = "20";
      "pm.max_requests" = "500";
    };
    config = {
      dbtype = "pgsql";
      dbuser = "nextcloud";
      dbpass = "nextcloud";
      dbtableprefix = "oc_";
      adminpass = "nextlcoud";
    };
  };

  services.searx.enable = true;

  users.users.gitea.uid = 998;
  users.groups.gitea.gid = 492;
  services.gitea = {
    enable = true;
    cookieSecure = true;
    httpPort = 30006;
    rootUrl = "https://git.${domain}/";
    disableRegistration = true;
    database = {
      type = "postgres";
      passwordFile = "/mnt/secrets/gitea-db";
    };
  };

  services.shellinabox = {
    enable = true;
    extraOptions = [ "--css ${../../misc/white-on-black.css}" ];
  };

  services.jellyfin.enable = true;
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
      ${config.services.roundcube.hostName} = {
        listen = [ { addr = "127.0.0.1"; port = 30005; } ];
        forceSSL = false;
        enableACME = false;
      };
      "riot" = {
        listen = [ { addr = "127.0.0.1"; port = 30001; } ];
        locations = { "/" = { root = pkgs.riot-web; }; };
      };
      "wedding" = {
        listen = [ { addr = "127.0.0.1"; port = 30002; } ];
        locations = { "/" = { root = "/var/www/wedding"; }; };
      };
      "vilodec" = {
        listen = [ { addr = "127.0.0.1"; port = 30004; } ];
        locations = { "/" = {
          root = "/var/www/vilodec";
          index = "index.php";
          extraConfig = ''
            location ~* \.php$ {
              fastcgi_split_path_info ^(.+\.php)(/.+)$;
              fastcgi_pass unix:${config.services.phpfpm.pools.web.socket};
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
        listen = [ { addr = "127.0.0.1"; port = 30007; } ];
        extraConfig = ''
          # static files
          location ^~ /loleaflet {
              proxy_pass https://localhost:9980;
              proxy_set_header Host $host;
          }

          # WOPI discovery URL
          location ^~ /hosting/discovery {
              proxy_pass https://localhost:9980;
              proxy_set_header Host $host;
          }

          # main websocket
          location ~ ^/lool/(.*)/ws$ {
              proxy_pass https://localhost:9980;
              proxy_set_header Upgrade $http_upgrade;
              proxy_set_header Connection "Upgrade";
              proxy_set_header Host $host;
              proxy_read_timeout 36000s;
          }

          # download, presentation and image upload
          location ~ ^/lool {
              proxy_pass https://localhost:9980;
              proxy_set_header Host $host;
          }

          # Admin Console websocket
          location ^~ /lool/adminws {
              proxy_pass https://localhost:9980;
              proxy_set_header Upgrade $http_upgrade;
              proxy_set_header Connection "Upgrade";
              proxy_set_header Host $host;
              proxy_read_timeout 36000s;
          }
        '';
      };
      "apc.${domain}" = {
        listen = [ { addr = "127.0.0.1"; port = 30008; } ];
        locations = { "/" = { root = "/var/www/apc"; }; };
      };
    };
  };

  services.phpfpm.pools.web = {
    user = "nginx";
    settings = {
      "listen.owner" = "nginx";
      "listen.group" = "nginx";
      "listen.mode" = "0660";
      "user" = "nginx";
      "pm" = "dynamic";
      "pm.max_children" = "75";
      "pm.start_servers" = "2";
      "pm.min_spare_servers" = "1";
      "pm.max_spare_servers" =" 20";
      "pm.max_requests" = "500";
      "php_admin_value[error_log]" = "stderr";
      "php_admin_flag[log_errors]" = "on";
      "catch_workers_output" = "yes";
    };
  };

  ####################################
  ##            Databases           ##
  ####################################
  services.postgresql.enable = true;
  services.pgmanage.enable = true;
  services.pgmanage.port = 30003;
  services.pgmanage.connections = {
    localhost = "hostaddr=127.0.0.1 port=5432 dbname=postgres";
  };

  services.mysql.enable = true;
  services.mysql.package = pkgs.mysql;

  services.influxdb.enable = true;
  services.influxdb.dataDir = "/var/db/influxdb";

  ####################################
  ##         Communication          ##
  ####################################
  services.mailserver.enable = true;
  services.mailserver.domain = domain;

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
    tls_private_key_path = "/var/lib/acme/${domain}/key.pem";
    tls_certificate_path = "/var/lib/acme/${domain}/fullchain.pem";
    max_upload_size = "100M";
    url_preview_enabled = true;
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
  users.groups.acme.members = [ "matrix-synapse" ];
  systemd.services.matrix-synapse = {
    serviceConfig = {
      MemoryHigh = "3G";
      MemoryMax = "5G";
    };
  };
  services.mautrix-whatsapp = {
    enable = true;
    configOptions = {
      homeserver = {
        address = "https://matrix.${domain}";
        domain = "${domain}";
      };
      appservice = {
        address = http://localhost:8081;
        hostname = "0.0.0.0";
        port = 8081;
        database = {
          type = "sqlite3";
          uri = "/var/lib/mautrix-whatsapp/mautrix-whatsapp.db";
        };
        state_store_path = "/var/lib/mautrix-whatsapp/mx-state.json";
        id = "whatsapp";
        bot = {
          username = "whatsappbot";
          displayname = "WhatsApp Bot";
          #avatar = "mxc://maunium.net/NeXNQarUbrlYBiPCpprYsRqr";
        };
        as_token = "";
        hs_token = "";
      };
      bridge = {
        username_template = "whatsapp_{{.}}";
        displayname_template = "{{if .Notify}}{{.Notify}}{{else}}{{.Jid}}{{end}} (WA)";
        command_prefix = "!wa";
        permissions = {
          "@vskilet:sene.ovh" = "admin";
        };
      };
      logging = {
        directory = "/var/lib/mautrix-whatsapp/logs";
        file_name_format = "{{.Date}}-{{.Index}}.log";
        file_date_format = "2006-01-02";
        file_mode = 0384;
        timestamp_format = "Jan _2, 2006 15:04:05";
        print_level = "debug";
      };
    };
  };
  services.mautrix-telegram = {
    enable = true;
    config = {
      homeserver = {
        address = "https://matrix.${domain}";
        domain = "${domain}";
      };

      appservice = {
        bot_displayname = "Telegram Bot";
        provisioning.enabled = false;
        public = {
          enabled = true;
          prefix = "/public";
          external = "https://matrix.${domain}/public";
        };
      };

      bridge = {
        relaybot.authless_portals = false;
        permissions = {
          "*" = "relaybot";
          "@vskilet:sene.ovh" = "admin";
        };
      };

      telegram = {
        api_id = lib.fileContents /mnt/secrets/mautrix-telegram_api-id;
        api_hash = lib.fileContents /mnt/secrets/mautrix-telegram_api-hash;
      };

      logging = {
        loggers = {
          mau.level = "DEBUG";
          telethon.level = "DEBUG";
          aiohttp.level = "INFO";
        };
        root.level = "DEBUG";
      };
    };
  };

  ####################################
  ##          Supervision           ##
  ####################################
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
      cgroup = [
        {
          paths = [
            "/sys/fs/cgroup/memory/system.slice/*"
          ];
          files = ["memory.*usage*" "memory.limit_in_bytes"];
        }
        {
          paths = [
            "/sys/fs/cgroup/cpu/system.slice/*"
          ];
          files = ["cpuacct.usage" "cpu.cfs_period_us" "cpu.cfs_quota_us"];
        }
      ];
      smart = {
        path = "${pkgs.writeShellScriptBin "smartctl" "/run/wrappers/bin/sudo ${pkgs.smartmontools}/bin/smartctl $@"}/bin/smartctl";
      };
      exec= [
        {
          commands = [
            "${pkgs.python3}/bin/python ${pkgs.writeText "zpool.py" ''
              import json
              from subprocess import check_output

              columns = ["NAME", "SIZE", "ALLOC", "FREE", "CKPOINT", "EXPANDSZ", "FRAG", "CAP", "DEDUP", "HEALTH", "ALTROOT"]
              health = {'ONLINE':0, 'DEGRADED':11, 'OFFLINE':21, 'UNAVAIL':22, 'FAULTED':23, 'REMOVED':24}

              stdout = check_output(["${pkgs.zfs}/bin/zpool", "list", "-Hp"],encoding='UTF-8').split('\n')
              parsed_stdout = list(map(lambda x: dict(zip(columns,x.split('\t'))), stdout))[:-1]

              for pool in parsed_stdout:
                for item in pool:
                  if item in ["SIZE", "ALLOC", "FREE", "FRAG", "CAP"]:
                    pool[item] = int(pool[item])
                  if item in ["DEDUP"]:
                    pool[item] = float(pool[item])
                  if item == "HEALTH":
                    pool[item] = health[pool[item]]

              print(json.dumps(parsed_stdout))
            ''}"
          ];
          tag_keys = [ "NAME" ];
          data_format = "json";
          name_suffix = "_python_zpool";
        }
      ];
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

  services.smartd = {
    enable = true;
    defaults.monitored = "-a -o on -s (S/../.././03|L/../../7/04)";
    notifications.mail = {
      enable = true;
      recipient = "victor@sene.ovh";
    };
  };

  ####################################
  ##            Security            ##
  ####################################
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
