{ pkgs, config, lib, ... }:

{
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
      net = { interfaces = [ "eno1" "eno2" "eno3" "eno4" ]; };
      netstat = {};
      cpu = { totalcpu = true; };
      sensors = {};
      kernel = {};
      mem = {};
      swap = {};
      processes = {};
      system = {};
      disk = {};
      http_response = {
        urls = [
          "https://chat.sene.ovh" "https://cloud.sene.ovh" "https://git.sene.ovh" "https://grafana.sene.ovh" "https://home.sene.ovh" "https://login.sene.ovh" "https://matrix.sene.ovh" "https://meet.sene.ovh" "https://unifi.sene.ovh" "https://videos.sene.ovh"

          "https://unionapc.fr" "https://missionfpc.fr"
          "http://www.lecentrebiblique.fr" "https://www.lecnef.org" "http://www.reseaufef.com/"
        ];
        follow_redirects = true;
        response_timeout = "3s";
      };
      cgroup = [
        {
          paths = [
            "/sys/fs/cgroup/system.slice/*"
          ];
          files = ["memory.current" "cpu.stat"];
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
    dataDir = "/var/lib/grafana";
    settings = {
      server = {
        root_url = "https://grafana.sene.ovh";
        http_addr = "127.0.0.1";
        http_port = 3000;
      };
      smtp = {
        enabled = true;
        from_address = "grafana@sene.ovh";
      };
      "auth.anonymous" = {
        enabled = true;
        org_name = "SENE-NET";
        org_role = "Admin";
      };
      auth = {
        basic_enabled = false;
        disable_login_form = true;
        disable_signout_menu = true;
      };
    };
  };

  services.smartd = {
    enable = true;
    defaults.monitored = "-a -o on -s (S/../.././03|L/../../7/04)";
    notifications.mail = {
      enable = true;
      sender = "smartd@sene.ovh";
      recipient = "victor@sene.ovh";
    };
  };

  services.nginx.virtualHosts."grafana.sene.ovh" = {
    enableACME = true;
    forceSSL   = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString(config.services.grafana.settings.server.http_port)}/";
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
