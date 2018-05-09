{ config, lib, pkgs, ... }:

with lib;

let

  haproxy_backends = {
    "grafana.sene.ovh" = { ip = "127.0.0.1"; port = 3000; auth = false; };
    "stream.sene.ovh" = { ip = "127.0.0.1"; port = 8096; auth = false; };
    "seed.sene.ovh" = { ip = "127.0.0.1"; port = 9091; auth = true; };
    "cloud.sene.ovh" = { ip = "127.0.0.1"; port = 8441; auth = false; };
    "searx.sene.ovh" = { ip = "127.0.0.1"; port = 8888; auth = false; };
    "shell.sene.ovh" = { ip = "127.0.0.1"; port = 4200; auth = true; };
    "riot.sene.ovh" = { ip = "127.0.0.1"; port = riot_port; auth = false; };
    "matrix.sene.ovh" = { ip = "127.0.0.1"; port = 8008; auth = false; };
    "sync.sene.ovh" = { ip = "127.0.0.1"; port = 5000; auth = false; };
    "constanceetvictor.fr" = { ip = "127.0.0.1"; port = wedding_port; auth = false; };

  };

  domain = "sene.ovh";
  riot_port = 30001;
  wedding_port = 30002;
in

{

  imports = [
    ./nextcloud.nix
    ./mailserver.nix
	];

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
      bind :::443 v4v6 ssl crt /var/lib/acme/${domain}/full.pem
      mode http
      acl letsencrypt-acl path_beg /.well-known/acme-challenge/
      redirect scheme https code 301 if !{ ssl_fc } !letsencrypt-acl
      use_backend letsencrypt-backend if letsencrypt-acl
      
      ${concatStrings (
      mapAttrsToList (name: value:
        " acl ${name}-acl hdr(host) -i ${name}\n"
      + " use_backend ${name}-backend if ${name}-acl\n"
      ) haproxy_backends)}
      
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
            "\n acl AuthOK_THELIST http_auth(THELIST)\n"
          + " http-request auth realm THELIST if !AuthOK_THELIST\n"
          ) else "")}
        ''
        ) haproxy_backends)}
  '';

  services.nginx.enable = true;
  services.nginx.virtualHosts = {
    "acme" = {
      listen = [ { addr = "127.0.0.1"; port = 54321; } ];
      locations = { "/" = { root = "/var/www/challenges"; }; };
    };
    "riot" = {
      listen = [ { addr = "127.0.0.1"; port = riot_port; } ];
      locations = { "/" = { root = pkgs.riot-web_custom; }; };
    };
    "wedding" = {
      listen = [ { addr = "127.0.0.1"; port = wedding_port; } ];
      locations = { "/" = { root = "/var/www/wedding"; }; };
    };
  };

  security.acme.certs = {
    ${domain} = {
      extraDomains = mapAttrs' (name: value:
        nameValuePair ("${name}") (null)
      ) haproxy_backends;
      webroot = "/var/www/challenges/";
      email = "victor@sene.ovh";
      user = "haproxy";
      group = "haproxy";
      postRun = "systemctl reload haproxy";
    };
  };
  security.acme.directory = "/var/lib/acme";
  
  
  services.influxdb.enable = true;
  services.influxdb.dataDir = "/var/db/influxdb";

  services.telegraf.enable = true;
  services.telegraf.extraConfig = {
    inputs = {
      net = { interfaces = [ "enp2s0" ]; };
      netstat = {};
      cpu = { totalcpu = true; };
      kernel = {};
      mem = {};
      processes = {};
      system = {};
      disk = {};
    };
    outputs = {
      influxdb = { database = "telegraf"; urls = [ "http://localhost:8086" ]; };
    };
  };
  
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
  
  services.nextcloud.enable = true;  
  services.nextcloud.vhosts = [ "cloud.${domain}" ];
  services.postgresql.enable = true;

  services.searx.enable = true;
  
  services.mailserver.enable = true;
  services.mailserver.domain = domain;

  services.shellinabox.enable = true;
  services.shellinabox.extraOptions = [ "--css ${./white-on-black.css}" ];

  nixpkgs.overlays = [ (self: super: { riot-web_custom = super.riot-web.override { conf = ''
    { 
      "default_hs_url": "https://matrix.sene.ovh",
      "default_is_url": "https://vector.im",
      "brand": "SENE-NET",
      "default_theme": "dark"
    }
  ''; }; } ) ];

  services.matrix-synapse = {
    enable = true;
    enable_registration = true;
    server_name = "sene.ovh";
    listeners = [
      { # federation
        bind_address = "";
        port = 8448;
        resources = [
          { compress = true; names = [ "client" "webclient" ]; }
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
          { compress = true; names = [ "client" "webclient" ]; }
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
    extraConfig = ''
      max_upload_size: "100M"
    '';
  };
  
  networking.firewall.allowedTCPPorts = [
    80 443 # HAProxy
    51413 # Transmission
    8448 # Matrix
  ];
  networking.firewall.allowedUDPPorts = [
    51413 # Transmission
  ];
}
