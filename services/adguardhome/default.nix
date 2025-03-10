{ pkgs, config, lib, ... }:

{
  services.kresd.enable = lib.mkForce false;
  services.adguardhome = {
    enable = true;
    port = 10003;
    settings = {
      http = {
        address = "127.0.0.1:10003";
      };
      dns = {
        bind_hosts = [
          "0.0.0.0"
        ];
        upstream_dns = [
          "80.67.169.12"
          "80.67.169.40"
          "89.234.141.66"
          "1.1.1.1"
        ];
      };
      filtering = {
        protection_enabled = true;
        filtering_enabled = true;
        parental_enabled = false;  # Parental control-based DNS requests filtering.
        safe_search = {
          enabled = false;  # Enforcing "Safe search" option for search engines, when possible.
        };
      };
      filters = map(url: { enabled = true; url = url; }) [
        "https://adguardteam.github.io/HostlistsRegistry/assets/filter_9.txt"  # The Big List of Hacked Malware Web Sites
        "https://adguardteam.github.io/HostlistsRegistry/assets/filter_11.txt"  # malicious url blocklist
      ];
    };
  };

  services.nginx.virtualHosts."dns.sene.ovh" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://${toString(config.services.adguardhome.settings.http.address)}/";
      extraConfig = ''
        auth_request_set $cookie $upstream_http_set_cookie;
        add_header Set-Cookie $cookie;
      '';
    };
    extraConfig = ''
      include ${toString(config.environment.etc."nginx-sso_auth.inc".source)};
    '';
  };

  networking.firewall = {
    allowedUDPPorts = [ 53 ];
    allowedTCPPorts = [ 53 ];
  };
}
