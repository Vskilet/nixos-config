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
        blocked_services = {
          ids = [
            "onlyfans"
          ];
        };
        bootstrap_dns = [
          "86.54.11.11"
          "86.54.11.211"
          "2a13:1001::86:54:11:11"
          "2a13:1001::86:54:11:211"
        ];
        fallback_dns = [
          "https://ns1.fdn.fr/dns-query"
          "1.1.1.1"
        ];
        upstream_dns = [
          "https://unfiltered.joindns4.eu/dns-query"
          "https://ns0.fdn.fr/dns-query"
          "https://dns.nextdns.io"
          "89.234.141.66"           # Alsace Reseau Neutre
          "2a00:5881:8100:1000::3"  # Alsace Reseau Neutre
        ];
        upstream_mode = "load_balance";
      };
      filtering = {
        protection_enabled = true;
        filtering_enabled = true;
        parental_enabled = true;  # Parental control-based DNS requests filtering.
        safe_search = {
          enabled = false;  # Enforcing "Safe search" option for search engines, when possible.
        };
      };
      filters = map(url: { enabled = true; url = url; }) [
        "https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt"   # AdGuard DNS filter
        "https://adguardteam.github.io/HostlistsRegistry/assets/filter_9.txt"   # The Big List of Hacked Malware Web Sites
        "https://adguardteam.github.io/HostlistsRegistry/assets/filter_11.txt"  # malicious url blocklist
      ];
      language = "fr";
      theme = "dark";
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
