{ config, pkgs, ... }:

{
  services.haproxy.enable = true;
  services.haproxy.config = ''
    global
      log /dev/log local0
      log /dev/log local1 notice
      user haproxy
      group haproxy
      ssl-default-bind-ciphers ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256
      ssl-default-bind-options no-sslv3 no-tlsv10 no-tlsv11 no-tls-tickets
      ssl-default-server-ciphers ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256
      ssl-default-server-options no-sslv3 no-tlsv10 no-tlsv11 no-tls-tickets
    defaults
      option forwardfor
      option http-server-close
    userlist THELIST
      user victor password $6$6rDdCtzSVsAwB6KP$V8bR7KP7FSL2BSEh6n3op6iYhAnsVSPI2Ar3H6MwKrJ/lZRzUI8a0TwVBD2JPnAntUhLpmRudrvdq2Ls2odAy.
    frontend public
      bind :::80 v4v6
      bind :::443 v4v6 ssl crt /var/lib/acme/sene.ovh/full.pem
      mode http
      acl letsencrypt-acl path_beg /.well-known/acme-challenge/
      use_backend letsencrypt-backend if letsencrypt-acl
      redirect scheme https code 301 if !{ ssl_fc } !letsencrypt-acl
      acl grafana-acl hdr(host) -i grafana.sene.ovh
      acl emby-acl hdr(host) -i emby.sene.ovh
      acl transmission-acl hdr(host) -i transmission.sene.ovh
      use_backend grafana-backend if grafana-acl
      use_backend emby-backend if emby-acl
      use_backend transmission-backend if transmission-acl
    backend letsencrypt-backend
      mode http
      server letsencrypt 127.0.0.1:54321
    backend grafana-backend
      mode http
      server grafana 127.0.0.1:3000 check
    backend emby-backend
      mode http
      server emby 127.0.0.1:8096 check
    backend transmission-backend
      mode http
      acl AuthOK_THELIST http_auth(THELIST)
      http-request auth realm THELIST if !AuthOK_THELIST
      server transmission 127.0.0.1:9091 check
  '';

  services.nginx.enable = true;
  services.nginx.virtualHosts = {
    "acme" = {
      listen = [ { addr = "127.0.0.1"; port = 54321; } ];
      locations = { "/" = { root = "/var/www/challenges"; }; };
    };
  };

  security.acme.certs = {
    "sene.ovh" = {
      extraDomains = {
        "grafana.sene.ovh" = null;
        "emby.sene.ovh" = null;
        "transmission.sene.ovh" = null;
      };
      webroot = "/var/www/challenges/";
      email = "victor@sene.ovh";
      user = "haproxy";
      group = "haproxy";
    };
  };
  security.acme.directory = "/var/lib/acme";

  services.emby.enable = true;
  services.emby.dataDir = "/var/lib/emby/ProgramData-Server";

  services.grafana.enable = true;
  services.grafana.addr = "127.0.0.1";
  services.grafana.dataDir = "/var/lib/grafana";

  services.transmission.enable = true;
  services.transmission.home = "/var/lib/transmission";
  services.transmission.settings = {
    rpc-bind-address = "127.0.0.1";
    rpc-host-whitelist = "*";
    rpc-whitelist-enabled = false;
  };

  networking.firewall.allowedTCPPorts = [
    80 443 # HAProxy
    51413 # Transmission
  ];
  networking.firewall.allowedUDPPorts = [
    51413 # Transmission
  ];
}
