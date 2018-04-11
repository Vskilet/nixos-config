{ config, pkgs, ... }:

with lib;

let

  haproxy_backends = {
    grafana = { ip = "127.0.0.1"; port = 3000; auth = false; };
    emby = { ip = "127.0.0.1"; port = 8096; auth = false; };
    transmission = { ip = "127.0.0.1"; port = 9091; auth = true; };
  };

  domain = "freebox.sene.ovh";

in

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
      user victor password $6$WOpUfphaCRCpPEti$xn5np2mS.64b41lb31vWFQV/GKtW//VWJ/xiWAEECWPDsUfrk0P2h3g2TimztIK1JIcvzIxGCLYzzAGXaGfCl1
    frontend public
      bind :::80 v4v6
      bind :::443 v4v6 ssl crt /var/lib/acme/${domain}/full.pem
      mode http
      acl letsencrypt-acl path_beg /.well-known/acme-challenge/
      redirect scheme https code 301 if !{ ssl_fc } !letsencrypt-acl
      use_backend letsencrypt-backend if letsencrypt-acl
      
      ${concatStrings (
      mapAttrsToList (name: value:
        "
  acl ${name}-acl hdr(host) -i ${name}.${domain}
  use_backend ${name}-backend if ${name}-acl
        ") haproxy_backends)}
      
    backend letsencrypt-backend
      mode http
      server letsencrypt 127.0.0.1:54321
    
    ${concatStrings (
      mapAttrsToList (name: value:
        ''
    backend ${name}-backend
        mode http
        server ${name} ${value.ip}:${toString value.port}
        ${(if value.auth then (
            "
        acl AuthOK_LOUTRE http_auth(LOUTRE)
        http-request auth realm LOUTRE if !AuthOK_LOUTRE
            ") else "")}
                ''
                ) haproxy_backends)}
  '';

  services.nginx.enable = true;
  services.nginx.virtualHosts = {
    "acme" = {
      listen = [ { addr = "127.0.0.1"; port = 54321; } ];
      locations = { "/" = { root = "/var/www/challenges"; }; };
    };
  };

  security.acme.certs = {
    ${domain} = {
      extraDomains = mapAttrs' (name: value:
        nameValuePair ("${name}.${domain}") (null)
      ) haproxy_backends;
      webroot = "/var/www/challenges/";
      email = "victor@sene.ovh";
      user = "haproxy";
      group = "haproxy";
      postRun = "systemctl reload haproxy";
    };
  };
  security.acme.directory = "/var/lib/acme";
  

  services.grafana.enable = true;
  services.grafana.addr = "127.0.0.1";
  services.grafana.dataDir = "/var/lib/grafana";

  services.emby.enable = true;
  services.emby.dataDir = "/var/lib/emby/ProgramData-Server";

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
