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
      sender = "smartd@sene.ovh";
      recipient = "victor@sene.ovh";
    };
  };

  services.nginx.virtualHosts."grafana.sene.ovh" = {
    enableACME = true;
    forceSSL   = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString(config.services.grafana.port)}/";
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
