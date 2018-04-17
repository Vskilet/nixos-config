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
      url = "https://github.com/r-raymond/nixos-mailserver/archive/v2.1.4.tar.gz";
      sha256 = "1n7k8vlsd1p0fa7s3kgd40bnykpk7pv579aqssx9wia3kl5s7c1b";
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
          hashedPassword = "$6$uQnAYIZbb5ILQz$OscV9Kby46QIzOkqhLhShxf14aLabbEKB6nqnaf0YkSlQCDz6Tby1vqI9zEfCYik2D7bvVtocZ3itvRPQ6QXJ/";
        };
      };

      # Certificate setup
      certificateScheme = 1;
      certificateFile = "/var/lib/acme/${cfg.domain}/fullchain.pem";
      keyFile = "/var/lib/acme/${cfg.domain}/key.pem";

      # Length of the Diffie Hillman prime used
      dhParamBitLength = 4096;

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
      };
    };
  };
}

