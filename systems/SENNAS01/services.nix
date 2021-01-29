{ config, lib, pkgs, ... }:

with lib;

let
  domain = "sene.ovh";
  jellyfin_backend = ''
    http-request set-header X-Forwarded-Port %[dst_port]
    http-request add-header X-Forwarded-Proto https if { ssl_fc }
  '';

  nginxSsoAuth = pkgs.writeText "nginx-sso_auth.inc" ''
    # Protect this location using the auth_request
    auth_request /sso-auth;

    # Redirect the user to the login page when they are not logged in
    error_page 401 = @error401;

    location /sso-auth {
        # Do not allow requests from outside
        internal;

        # Access /auth endpoint to query login state
        proxy_pass http://127.0.0.1:${toString(config.services.nginx.sso.configuration.listen.port)}/auth;

        # Do not forward the request body (nginx-sso does not care about it)
        proxy_pass_request_body off;
        proxy_set_header Content-Length "";

        # Set custom information for ACL matching: Each one is available as
        # a field for matching: X-Host = x-host, ...
        proxy_set_header X-Origin-URI $request_uri;
        proxy_set_header X-Host $http_host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # If the user is lead to /logout redirect them to the logout endpoint
    # of ngninx-sso which then will redirect the user to / on the current host
    location /sso-logout {
        return 302 https://login.sene.ovh/logout?go=$scheme://$http_host/;
    }

    # Define where to send the user to login and specify how to get back
    location @error401 {
        return 302 https://login.sene.ovh/login?go=$scheme://$http_host$request_uri;
    }
  '';
in
{
  imports = [
    ../../services/mailserver.nix
    ../../services/mautrix-whatsapp.nix
  ];

  services.unifi = {
    enable = true;
    unifiPackage = pkgs.unifiBeta;
    openPorts = true;
  };

  ####################################
  ##          WEB services          ##
  ####################################

  security.acme = {
    email = "victor@sene.ovh";
    acceptTerms = true;
  };
  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    commonHttpConfig = ''
      map $scheme $hsts_header {
        https   "max-age=31536000; includeSubdomains; preload";
      }
      add_header Strict-Transport-Security  $hsts_header;
      add_header Referrer-Policy            origin-when-cross-origin;

      error_page 500 502 503 504 https://sene.ovh/errorpages/50x.html;
    '';
    sso = {
      enable = true;
      environmentFile = "/mnt/secrets/nginx-sso.env";
      configuration = {
        listen = {
          addr = "127.0.0.1";
          port = 8082;
        };
        login = {
          title = "SENE-NET login";
          default_method = "simple";
          hide_mfa_field = true;
          names.simple = "Username / Password";
        };
        cookie = {
          domain = ".sene.ovh";
          secure = true;
        };
        audit_log = {
          targets = [ "fd://stdout" ];
          events = [ "access_denied" "login_success" "login_failure" "logout" ];
        };
        providers.simple = {
          enable_basic_auth = true;
          users = {
            victor = "$2y$10$8OeX2FlnodZgx9QoYRugq.ObARUy6sMfop6wasoaRgjtXU7ZdHnOC";
          };
          groups = {
            admins = [ "victor" ];
          };
        };
        acl = {
          rule_sets = [
            {
              rules = [ { field = "x-host"; regexp = ".*"; } ];
              allow = [ "@admins" ];
            }
          ];
        };
      };
    };
    virtualHosts = let
      base = locations: {
        inherit locations;
        forceSSL = true;
        enableACME = true;
      };
      simpleReverse = targetport: base {
        "/" = {
          proxyPass = "http://127.0.0.1:${toString(targetport)}/";
        };
      };
      authReverse = targetport: base {
        "/" = {
          proxyPass = "http://127.0.0.1:${toString(targetport)}/";
          extraConfig = ''
            auth_request_set $cookie $upstream_http_set_cookie;
            add_header Set-Cookie $cookie;
          '';
        };
      } // {
        extraConfig = ''
          include ${nginxSsoAuth};
        '';
      };
    in {
      "sene.ovh" = {
        default = true;
        enableACME = true;
        forceSSL = true;
        serverAliases = [ "stech.ovh" ];
        locations = {
          "/" = {
            alias = "/var/www/frontpage/";
          };
          "/errorpages/" = {
            alias = "/var/www/errorpages/";
          };
        };
      };
      "login.sene.ovh" = {
        enableACME = true;
        forceSSL = true;

        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString(config.services.nginx.sso.configuration.listen.port)}/";
      	};
      };
      "riot.sene.ovh" = {
        enableACME = true;
        forceSSL = true;
        serverAliases = [ "chat.sene.ovh" ];
        locations = { "/" = { root = pkgs.element-web; }; };
      };
      "cloud.sene.ovh" = {
        enableACME = true;
        forceSSL = true;
        serverAliases = [ "cloud.stech.ovh" ];
      };
      "onlyoffice.sene.ovh" = simpleReverse 9981;
      "matrix.sene.ovh" = simpleReverse 8008;
      "searx.sene.ovh" = simpleReverse 8888;
      "git.sene.ovh" = simpleReverse config.services.gitea.httpPort;
      "git.stech.ovh" = simpleReverse config.services.gitea.httpPort;
      "seed.sene.ovh" = authReverse config.services.transmission.port;
      "pgmanage.sene.ovh" = authReverse config.services.pgmanage.port;
      "grafana.sene.ovh" = authReverse config.services.grafana.port;
      "grafana.stech.ovh" = authReverse config.services.grafana.port;
      "unifi.sene.ovh" = {
	enableACME = true;
        forceSSL = true;
        serverAliases = [ "unifi.stech.ovh" ];
        locations = {
	  "/" = {
            extraConfig = ''
	      proxy_pass_header Authorization;
	      proxy_pass https://127.0.0.1:8443/;
	      proxy_set_header Host $host;
	      proxy_set_header X-Real-IP $remote_addr;
	      proxy_set_header X-Forwarded-Host $host;
	      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
	      proxy_set_header X-Forwarded-Proto $scheme;
            '';
          };
	  "/wss/" = {
            extraConfig = ''
              proxy_pass https://127.0.0.1:8443;
              proxy_http_version 1.1;
              proxy_buffering off;
              proxy_set_header Upgrade $http_upgrade;
              proxy_set_header Connection "Upgrade";
              proxy_read_timeout 86400;
	    '';
	  };
	};
      };
      "stream.sene.ovh" = simpleReverse 8096;
      "videos.sene.ovh" = {
      	enableACME = true;
        forceSSL = true;
        serverAliases = [ "videos.stech.ovh" ];
        locations = { "/" = {
          proxyPass = "http://127.0.0.1:9000/";
          extraConfig = ''
            client_max_body_size 5G;
          '';
        }; };
      };
    };
  };

  services.nextcloud = {
    enable = true;
    hostName = "cloud.sene.ovh";
    https = true;
    package = pkgs.nextcloud20;
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
      dbpassFile = "/mnt/secrets/nextcloud_config_dbpassFile";
      dbtableprefix = "oc_";
      adminpassFile = "/mnt/secrets/nextcloud_config_adminpassFile";
      extraTrustedDomains = config.services.nginx.virtualHosts."cloud.sene.ovh".serverAliases;
    };
  };

  services.searx.enable = true;

  users.users.gitea.uid = 998;
  users.groups.gitea.gid = 492;
  services.gitea = {
    enable = true;
    cookieSecure = true;
    httpPort = 30006;
    rootUrl = "https://git.sene.ovh/";
    disableRegistration = true;
    database = {
      type = "postgres";
      passwordFile = "/mnt/secrets/gitea_database_passwordFile";
    };
    settings = {
      server = {
        LANDING_PAGE = "explore";
      };
    };
  };

  services.jellyfin = {
    enable = true;
    package = pkgs.jellyfin;
  };

  services.transmission = {
    enable = true;
    home = "/var/lib/transmission";
    port = 9091;
    openFirewall = true;
    settings = {
      download-dir = "/mnt/medias/downloads/";
      incomplete-dir = "/mnt/medias/downloads/.incomplete";
      incomplete-dir-enabled = true;
      rpc-bind-address = "127.0.0.1";
      rpc-host-whitelist = "*";
      rpc-whitelist-enabled = false;
      peer-port = 51413;
    };
  };
  systemd.services.transmission.serviceConfig.BindPaths = [ "/mnt/medias/" ];

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

  services.nfs.server = {
    enable = true;
    exports = ''
      /mnt/medias  192.168.1.0/24(ro,no_root_squash)
    '';
    statdPort = 4000;
    lockdPort = 4001;
    mountdPort = 4002;
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

  services.influxdb.enable = true;
  services.influxdb.dataDir = "/var/db/influxdb";

  ####################################
  ##         Communication          ##
  ####################################
  services.mailserver = {
    enable = true;
    fqdn = "sene.ovh";
    domains = [ "sene.ovh" "stech.ovh"];
  };

  services.jitsi-meet = {
    enable = true;
    hostName = "meet.sene.ovh";
    config = {
      enableWelcomePage = true;
      prejoinPageEnabled = true;
      defaultLang = "fr";
      enableNoisyMicDetection = false;
    };
    interfaceConfig = {
      SHOW_JITSI_WATERMARK = false;
      SHOW_WATERMARK_FOR_GUESTS = false;
      DISABLE_VIDEO_BACKGROUND = true;
      PROVIDER_NAME = "sene.ovh";
      DISABLE_JOIN_LEAVE_NOTIFICATIONS = true;
    };
  };
  services.jitsi-videobridge = {
    openFirewall = true;
    nat = {
      localAddress = "192.168.1.12";
      #config.networking.interfaces."enp2s0".ipv4.addresses.0.address;
      publicAddress = "176.179.179.58";
    };
  };
  boot.kernel.sysctl."net.core.rmem_max" = 10485760;

  services.matrix-synapse = {
    enable = true;
    enable_registration = true;
    server_name = "sene.ovh";
    listeners = [
      { # federation
        bind_address = "";
        port = 8448;
        resources = [
          { compress = true; names = [ "client" ]; }
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
          { compress = true; names = [ "client" ]; }
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
    tls_private_key_path = "/var/lib/acme/sene.ovh/key.pem";
    tls_certificate_path = "/var/lib/acme/sene.ovh/fullchain.pem";
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
  users.groups.${toString(config.services.nginx.group)}.members = [ "matrix-synapse" ];

  services.mautrix-whatsapp = {
    enable = true;
    configOptions = {
      homeserver = {
        address = "https://matrix.sene.ovh";
        domain = "sene.ovh";
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
        displayname_template = "{{if .Notify}}{{.Notify}}{{else}}{{.Jid}}{{end}}";
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
        print_level = "error";
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
      SERVER_ROOT_URL = "https://grafana.sene.ovh";
      SMTP_ENABLED = "true";
      SMTP_FROM_ADDRESS = "grafana@sene.ovh";
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
    80
    443
    8448 # Matrix Federation
    1935 # RTMP
    111 2049 4000 4001 4002 # NFS
  ];
  networking.firewall.allowedUDPPorts = [
    111 2049 4000 4001 4002 # NFS
  ];
}
