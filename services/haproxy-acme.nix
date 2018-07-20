{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.haproxy-acme;
  nginx_port = 54321;
in
{
  options.services.haproxy-acme = {
    enable = mkEnableOption "HAProxy with ACME support";

    domain = mkOption {
      type = types.string;
      example = "sene.fr";
      description = ''
        This options list define the TLDN domain.
        You should use a wildcard which point on this server.
      '';
    };

    services = mkOption {
      type = with types; attrsOf (submodule { options = {
        ip = mkOption { type = str; description = "IP address"; };
        port = mkOption { type = int; description = "Port number"; };
        auth = mkOption { type = bool; description = "Enable authentification"; default = false; };
      }; });
      example = ''
        haproxy_backends = {
          joie.sene.fr = { ip = "127.0.0.1"; port = 1234; auth = false; };
        };
      '';
      description = ''
        This options list all subdomains/domains whith there backend port that you want to use and cert.
        Please use all url to describe correctly your subdomain.
      '';
    };
  };

  config = mkIf cfg.enable {
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
        user victor password $6$aydejDVvpYbZ$..iTobk0.7KzY9DEwB5BWGwudnyqeYtxMITijr48HvjjyqbR1S/fn1zS3GS2n6n2UGEWKORYmPPt8QGRFxvX70
      frontend public
        bind :::80 v4v6
        bind :::443 v4v6 ssl crt /var/lib/acme/${cfg.domain}/full.pem alpn h2,http/1.1
        mode http
        acl letsencrypt-acl path_beg /.well-known/acme-challenge/
        acl haproxy-acl path_beg /haproxy
        redirect scheme https code 301 if !{ ssl_fc } !letsencrypt-acl
        http-response set-header Strict-Transport-Security max-age=15768000
        use_backend letsencrypt-backend if letsencrypt-acl
        use_backend haproxy_stats if haproxy-acl
        
        ${concatStrings (
        mapAttrsToList (name: value:
          " acl ${name}-acl hdr(host) -i ${name}\n"
        + " use_backend ${name}-backend if ${name}-acl\n"
        ) cfg.services)}
        
      backend letsencrypt-backend
        mode http
        server letsencrypt 127.0.0.1:${toString nginx_port}
      backend haproxy_stats
        mode http
        stats enable
        stats hide-version 
        acl AuthOK_THELIST http_auth(THELIST)
        http-request auth realm THELIST if !AuthOK_THELIST

      ${concatStrings (
        mapAttrsToList (name: value:
          ''
          backend ${name}-backend
            mode http
            server ${name} ${value.ip}:${toString value.port}
            ${(if value.auth then (
              "\n acl AuthOK_THELIST http_auth(THELIST)\n"
            + " http-request auth realm THELIST if !AuthOK_THELIST\n"
            ) else "")}
          ''
          ) cfg.services)}
    '';
    
    services.nginx.enable = true;
    services.nginx.virtualHosts = {
      "acme" = {
        listen = [ { addr = "127.0.0.1"; port = nginx_port; } ];
        locations = { "/" = { root = "/var/www/challenges"; }; };
      };
    };
    
    security.acme.certs = {
      "${cfg.domain}" = {
        extraDomains = mapAttrs' (name: value:
          nameValuePair ("${name}") (null)
        ) cfg.services;
        webroot = "/var/www/challenges/";
        email = "victor@sene.ovh";
        user = "haproxy";
        group = "haproxy";
        postRun = ''
          systemctl reload haproxy
        '';
      };
    };
    security.acme.directory = "/var/lib/acme";
    networking.firewall.allowedTCPPorts = [
      80 443 # HAProxy
    ];
  };
}