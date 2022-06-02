{ config, lib, pkgs, ... }:

let
  domain = "sene.ovh";
in
{
  security.acme = {
    defaults.email = "victor@sene.ovh";
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
      configuration = {
        listen = {
          addr = "127.0.0.1";
          port = 8082;
        };
        login = {
          title = "STECH Corp.";
          default_method = "simple";
          hide_mfa_field = true;
          names.simple = "Username / Password";
        };
        cookie = {
          domain = ".sene.ovh";
          expire = 10800;
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
    virtualHosts = {
      "sene.ovh" = {
        default = true;
        enableACME = true;
        forceSSL = true;
        serverAliases = [ "stech.ovh" ];
        locations = {
          "/" = {
            root = fetchGit {
              url = "https://git.sene.ovh/victor/frontpage.git";
              rev = "aec463e215d34d394130a072fa86b476fbe52392";
              ref = "refs/heads/master";
            };
          };
          "/errorpages/" = {
            alias = "/var/www/errorpages/";
          };
          "/.well-known/matrix/server" = {
            extraConfig =
              let
                # use 443 instead of the default 8448 port to unite
                # the client-server and server-server port for simplicity
                server = { "m.server" = "matrix.sene.ovh:443"; };
              in ''
                add_header Content-Type application/json;
                return 200 '${builtins.toJSON server}';
              '';
          };
          "/.well-known/matrix/client" = {
            extraConfig =
              let
                client = {
                  "m.homeserver" =  { "base_url" = "https://matrix.sene.ovh"; };
                  "m.identity_server" =  { "base_url" = "https://vector.im"; };
                };
              # ACAO required to allow element-web on any URL to request this json file
              in ''
                add_header Content-Type application/json;
                add_header Access-Control-Allow-Origin *;
                return 200 '${builtins.toJSON client}';
              '';
          };
        };
      };
      "login.sene.ovh" = {
        enableACME = true;
        forceSSL = true;
        serverAliases = [ "login.stech.ovh" ];
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString(config.services.nginx.sso.configuration.listen.port)}/";
      	};
      };
      "hd.stech.ovh" = {
        enableACME = true;
        forceSSL = true;
        serverAliases = [ "www.hd.stech.ovh" ];
        locations."/" = {
          extraConfig = "return 301 https://dbeiner67.wixsite.com/monsite-1$request_uri;";
        };
      };
      "photos.stech.ovh" = {
        enableACME = true;
        forceSSL = true;
        serverAliases = [ "www.photos.stech.ovh" ];
        locations."/" = {
          extraConfig = "return 301 https://dbeiner67.wixsite.com/website$request_uri;";
        };
      };
    };
  };

  systemd.services.nginx-sso.serviceConfig.EnvironmentFile = "/mnt/secrets/nginx-sso.env";

  environment.etc."nginx-sso_auth.inc".text = ''
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

  services.phpfpm.pools.web = {
    user = "nginx";
    settings = {
      "listen.owner" = "nginx";
      "listen.group" = "nginx";
      "listen.mode" = "0660";
      "user" = "nginx";
      "pm" = "dynamic";
      "pm.max_children" = 75;
      "pm.start_servers" = 10;
      "pm.min_spare_servers" = 5;
      "pm.max_spare_servers" = 20;
      "pm.max_requests" = 500;
      "php_admin_value[error_log]" = "stderr";
      "php_admin_flag[log_errors]" = "on";
      "catch_workers_output" = "yes";
    };
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
}
