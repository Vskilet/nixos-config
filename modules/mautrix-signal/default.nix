{ config, pkgs, lib, ... }:

with lib;

let
  dataDir = "/var/lib/mautrix-signal";
  registrationFile = "${dataDir}/signal-registration.yaml";
  cfg = config.services.mautrix-signal;
  settingsFormat = pkgs.formats.json {};
  settingsFile = settingsFormat.generate "config.json" cfg.settings;
  #settingsFile = "${dataDir}/config.json";
  startupScript = ''
    ${pkgs.yq}/bin/yq -s '.[0].appservice.as_token = .[1].as_token
      | .[0].appservice.hs_token = .[1].hs_token
      | .[0]' ${settingsFile} ${registrationFile} \
      > ${dataDir}/config.yml

    ${pkgs.mautrix-signal}/bin/mautrix-signal \
      --config='${dataDir}/config.yml' \
      --registration='${registrationFile}'
  '';

in {
  options = {
    services.mautrix-signal = {
      enable = mkEnableOption "Mautrix-Signal a hybrid puppeting/relaybot bridge";

      settings = mkOption rec {
        apply = recursiveUpdate default;
        inherit (settingsFormat) type;
        default = {
          homeserver = {
            domain = config.services.matrix-synapse.settings.server_name;
          };
          appservice = rec {
            address = "http://localhost:${toString port}";
            hostname = "0.0.0.0";
            port = 29328;
            database = "sqlite:///${dataDir}/mautrix-signal.db";
            database_opts = {};
          };

          signal = {
            socket_path = "/run/signald/signald.sock";
            avatar_dir = "/var/lib/signald/avatars";
            data_dir = "/var/lib/signald/avatars";
          };

          bridge = {
            permissions."*" = "relaybot";
            relaybot.whitelist = [ ];
            login_shared_secret_map = {};
            double_puppet_server_map = {};
          };

          logging = {
            version = 1;

            formatters.precise.format = "[%(levelname)s@%(name)s] %(message)s";

            handlers.console = {
              class = "logging.StreamHandler";
              formatter = "precise";
            };

            loggers = {
              mau.level = "INFO";
              telethon.level = "INFO";

              # prevent tokens from leaking in the logs:
              # https://github.com/tulir/mautrix-signal/issues/351
              aiohttp.level = "WARNING";
            };

            # log to console/systemd instead of file
            root = {
              level = "INFO";
              handlers = [ "console" ];
            };
          };
        };
        example = literalExpression ''
          {
            homeserver = {
              address = "http://localhost:8008";
            };

            bridge.permissions = {
              "example.com" = "full";
              "@admin:example.com" = "admin";
            };
          }
        '';
        description = ''
          <filename>config.yaml</filename> configuration as a Nix attribute set.
          Configuration options should match those described in
          <link xlink:href="https://github.com/mautrix/signal/blob/master/mautrix_signal/example-config.yaml">
          example-config.yaml</link>.
        '';
      };

      serviceDependencies = mkOption {
        type = with types; listOf str;
        default = optional config.services.matrix-synapse.enable "matrix-synapse.service";
        defaultText = literalExpression ''
          optional config.services.matrix-synapse.enable "matrix-synapse.service"
        '';
        description = ''
          List of Systemd services to require and wait for when starting the application service.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.mautrix-signal = {
      description = "Mautrix-Signal, a Matrix-Signal hybrid puppeting/relaybot bridge.";

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ] ++ cfg.serviceDependencies;
      after = [ "network-online.target" ] ++ cfg.serviceDependencies;

      preStart = ''
        ${pkgs.yq}/bin/yq -s '.[0].appservice.as_token = .[1].as_token
          | .[0].appservice.hs_token = .[1].hs_token
          | .[0]' ${settingsFile} ${registrationFile} \
          > ${dataDir}/config.yml

        chmod 640 ${dataDir}/config.yml

        # generate the appservice's registration file if absent
        if [ ! -f '${registrationFile}' ]; then
          ${pkgs.mautrix-signal}/bin/mautrix-signal \
            --generate-registration \
            --base-config='${pkgs.mautrix-signal}/${pkgs.mautrix-signal.pythonModule.sitePackages}/mautrix_signal/example-config.yaml' \
            --config='${dataDir}/config.yml' \
            --registration='${registrationFile}'
        fi
      '';

      #script = startupScript;
      serviceConfig = {
        Type = "simple";
        Restart = "always";

        ProtectSystem = "strict";
        ProtectHome = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;

        #DynamicUser = true;
        PrivateTmp = true;
        WorkingDirectory = "${dataDir}";
        #pkgs.mautrix-signal; # necessary for the database migration scripts to be found
        StateDirectory = baseNameOf dataDir;
        UMask = 0027;
        Group = "matrix-synapse";

        ExecStart = ''
          ${pkgs.mautrix-signal}/bin/mautrix-signal \
            --config='${dataDir}/config.yml'
        '';
      };
    };

    users.groups.mautrix-signal = { };
    users.users.mautrix-signal = {
      isSystemUser = true;
      group = "mautrix-signal";
      home = dataDir;
    };

    services.matrix-synapse.settings.app_service_config_files = [ "${registrationFile}" ];

  };

  meta.maintainers = with maintainers; [ vskilet ];
}

