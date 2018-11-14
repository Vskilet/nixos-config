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
      type = types.string;
      example = "delabombe.com";
      description = "Domain name of the mail server";
    };
  };

  imports = [
    (builtins.fetchTarball {
      url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/v2.2.0/nixos-mailserver-v2.2.0.tar.gz";
      sha256 = "0gqzgy50hgb5zmdjiffaqp277a68564vflfpjvk1gv6079zahksc";
    })
  ];

  config = mkIf cfg.enable {

    mailserver = {
      enable = true;
      fqdn = "mail.${cfg.domain}";
      domains = [ cfg.domain ];

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
      enablePop3 = true;
      enableImapSsl = true;
      enablePop3Ssl = true;

      # Enable the ManageSieve protocol
      enableManageSieve = true;
    };

    security.acme.certs = {
      "${cfg.domain}" = {
        extraDomains = {
          "mail.${cfg.domain}" = null;
        };
        postRun = ''
          systemctl reload dovecot2.service
        '';
      };
    };
  };
}

