# Mail-Server
{ lib, config, pkgs, ... }:

with lib;

let
  cfg = config.services.mailserver;
in
{
  options.services.mailserver = {
    enable = mkEnableOption "Mail Server";
    domain = mkOption {
      type = types.str;
      description = "Principal domain name for the mail server";
    };
    adomain = mkOption {
      type = types.str;
    };
  };

  imports = [
    (builtins.fetchTarball {
      url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/master/nixos-mailserver-master.tar.gz";
      sha256 = "196wy23b3s0j2x9zb3kbvwzg29ww3arfr6z8pqdgmampba4npirb";
    })
  ];

  config = mkIf cfg.enable {

    mailserver = {
      enable = true;
      fqdn = "mail.${cfg.domain}";
      domains = [ cfg.domain cfg.adomain ];

      # A list of all login accounts. To create the password hashes, use
      # mkpasswd -m sha-512 "super secret password"
      loginAccounts = {
        "victor@${cfg.domain}" = {
          hashedPassword = "$6$SKy30uwxPvGAS4j0$yTEAL5VyOwTXnkdxI/Caj0F44S7yMT.7w28c61miDmV6Q59xV.so2ds7soP1eZ0a6tTSjmzZCXe2xXeFI8KVp/";
        };
        "constance@${cfg.domain}" = {
          hashedPassword = "$6$wGIPnWzZqfJD0.l$HpxYitiTsIWQVFoJOnJax5ZEJXucdhMsfc8vKgNzX7QfQQ/CSIwcozXfB49cqEXRivktd3aKcop1k7tCo840w/";
          aliases = ["douceurdecreation@${cfg.domain}"];
        };
        "prunille@${cfg.domain}" = {
          hashedPassword = "$6$0KdsLs/b5d8$WMs406bs/UxI.Gby36AWudtJ9G2plFucdOO/9wjUPDM5i9f.TSMV9leYjB/m4U2cu8xTVXY8WR5bPghEelsCs/";
        };

        "gaelle@${cfg.domain}" = {
          hashedPassword = "$6$hhEzaqBy1y$hmwRTOYWMmTZ8xJeShsQv4O4kmGB80slpI0R6UX1e8M53Gbg74tciQNd5fq4QqkUr5oCilc5b7b.E0spE5OtI.";
        };
      };

      # Certificate setup
      certificateScheme = 1;
      certificateFile = "/var/lib/acme/${cfg.domain}/fullchain.pem";
      keyFile = "/var/lib/acme/${cfg.domain}/key.pem";

      # Enable IMAP and POP3
      enableImap = true;
      enablePop3 = false;
      enableImapSsl = true;
      enablePop3Ssl = false;

      # Enable the ManageSieve protocol
      enableManageSieve = true;
    };

    security.acme.certs = {
      "${cfg.domain}" = {
        extraDomains = {
          "mail.${cfg.domain}" = null;
          "mail.${cfg.adomain}" = null;
        };
        postRun = ''
          systemctl reload dovecot2.service
        '';
      };
    };
  };
}

