# Mail-Server
{ lib, config, pkgs, ... }:

with lib;

let
  cfg = config.services.mailserver;
in
{
  options.services.mailserver = {
    enable = mkEnableOption "Mail Server";
    fqdn = mkOption {
      type = types.str;
      description = "Principal domain name for the mail server";
    };
    domains = mkOption {
      type = types.listOf types.str;
      example = [ "example.com" ];
      default = [];
      description = "The domains that this mail server serves.";
    };
  };

  imports = [
    (builtins.fetchTarball {
      url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/358cfcdfbe6ca137983c6629e174a98c306209cd/nixos-mailserver-358cfcdfbe6ca137983c6629e174a98c306209cd.tar.gz";
      sha256 = "0kib5qp4li4241yk474w1a7j1gsgb8gp3jj1sdhih22g40g69llb";
    })
  ];

  config = mkIf cfg.enable {

    mailserver = {
      enable = true;
      fqdn = "mail.${cfg.fqdn}";
      domains = cfg.domains;
      messageSizeLimit = 26214400;

      # A list of all login accounts. To create the password hashes, use
      # mkpasswd -m sha-512 "super secret password"
      loginAccounts = {
        "victor@${cfg.fqdn}" = {
          hashedPassword = "$6$SKy30uwxPvGAS4j0$yTEAL5VyOwTXnkdxI/Caj0F44S7yMT.7w28c61miDmV6Q59xV.so2ds7soP1eZ0a6tTSjmzZCXe2xXeFI8KVp/";
        };
        "constance@${cfg.fqdn}" = {
          hashedPassword = "$6$wGIPnWzZqfJD0.l$HpxYitiTsIWQVFoJOnJax5ZEJXucdhMsfc8vKgNzX7QfQQ/CSIwcozXfB49cqEXRivktd3aKcop1k7tCo840w/";
          aliases = [
            "constance.prowin@${cfg.fqdn}"
          ];
        };
        "prunille@${cfg.fqdn}" = {
          hashedPassword = "$6$0KdsLs/b5d8$WMs406bs/UxI.Gby36AWudtJ9G2plFucdOO/9wjUPDM5i9f.TSMV9leYjB/m4U2cu8xTVXY8WR5bPghEelsCs/";
        };

        "gaelle@${cfg.fqdn}" = {
          hashedPassword = "$6$hhEzaqBy1y$hmwRTOYWMmTZ8xJeShsQv4O4kmGB80slpI0R6UX1e8M53Gbg74tciQNd5fq4QqkUr5oCilc5b7b.E0spE5OtI.";
        };
        "sono.cb@${cfg.fqdn}" = {
          hashedPassword = "$6$9VdG71TJ4$eurEDwedEqA3TKeTpSI6l6r8MTRBpSGebIINusp0wxCNRt7AEwWWRGfp219oJgdCWqiYEB5DQzp.PXuQCkqVN0";
        };
        "david.beiner@stech.ovh" = {
          hashedPassword = "$6$RJf0cot4$IRLvlrf5SAqfRQML91U6TGYvYFMaYPUYn4zMKhczVhAhbeb.Ens8JUqPglA2h70e5deXMko/jAf6MLy3z3zxG1";
          aliases = [
            "david67@stech.ovh"
          ];
        };

      };

      # Certificate setup
      certificateScheme = 1;
      certificateFile = "/var/lib/acme/${cfg.fqdn}/fullchain.pem";
      keyFile = "/var/lib/acme/${cfg.fqdn}/key.pem";

      # Enable IMAP and POP3
      enableImap = true;
      enablePop3 = false;
      enableImapSsl = true;
      enablePop3Ssl = false;

      # Enable the ManageSieve protocol
      enableManageSieve = true;
    };

    security.acme.certs."${cfg.fqdn}" = {
      extraDomainNames = [ "mail.${cfg.fqdn}" ];
      postRun = ''
        systemctl reload dovecot2.service
      '';
    };
  };
}

