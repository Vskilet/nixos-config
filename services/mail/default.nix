{ lib, config, pkgs, ... }:

with lib;

let
  release = "master";
in
{
  imports = [
    (builtins.fetchTarball {
      url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/${release}/nixos-mailserver-${release}.tar.gz";
      sha256 = "1fllk14cqkpjwmf6nsy6mknn4gvxwqcl4ysyh5hxpn6axwfwjvnf";
      #sha256 = "160rc7w71rnysb19kp9rxzq0787azsivha72dspc5xzsijyk0977";
    })
  ];
  #imports = [
  #  (builtins.fetchGit {
  #    url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver";
  #    ref = "master";
  #    rev = "8b287056215cac91438a671054e7eb2c932ab21a";
  #  })
  #];

  mailserver = {
    enable = true;
    fqdn = "mail.sene.ovh";
    domains = [ "sene.ovh" "stech.ovh"];
    messageSizeLimit = 26214400;

    # A list of all login accounts. To create the password hashes, use
    # mkpasswd -m sha-512 "super secret password"
    loginAccounts = {
      "victor@sene.ovh" = {
        hashedPassword = "$6$SKy30uwxPvGAS4j0$yTEAL5VyOwTXnkdxI/Caj0F44S7yMT.7w28c61miDmV6Q59xV.so2ds7soP1eZ0a6tTSjmzZCXe2xXeFI8KVp/";
        aliases = [
          "contact@sene.ovh"
          "admin@sene.ovh"
        ];
      };
      "constance@sene.ovh" = {
        hashedPassword = "$6$wGIPnWzZqfJD0.l$HpxYitiTsIWQVFoJOnJax5ZEJXucdhMsfc8vKgNzX7QfQQ/CSIwcozXfB49cqEXRivktd3aKcop1k7tCo840w/";
        aliases = [
          "constance.prowin@sene.ovh"
        ];
      };
      "prunille@sene.ovh" = {
        hashedPassword = "$6$0KdsLs/b5d8$WMs406bs/UxI.Gby36AWudtJ9G2plFucdOO/9wjUPDM5i9f.TSMV9leYjB/m4U2cu8xTVXY8WR5bPghEelsCs/";
      };

      "gaelle@sene.ovh" = {
        hashedPassword = "$6$hhEzaqBy1y$hmwRTOYWMmTZ8xJeShsQv4O4kmGB80slpI0R6UX1e8M53Gbg74tciQNd5fq4QqkUr5oCilc5b7b.E0spE5OtI.";
      };
      "sono.cb@sene.ovh" = {
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
    certificateScheme = 3;
    #certificateFile = "/var/lib/acme/sene.ovh/fullchain.pem";
    #keyFile = "/var/lib/acme/sene.ovh/key.pem";

    # Enable IMAP and POP3
    enableImap = false;
    enablePop3 = false;
    enableImapSsl = true;
    enablePop3Ssl = false;
    #enableSubmission = false;
    enableSubmissionSsl = true;

    # Enable the ManageSieve protocol
    enableManageSieve = true;

    virusScanning = false;
  };

  services.postfix = {
    relayHost = "mailvps.nyanlout.re";
    relayPort = 587;
    config = {
      smtp_tls_cert_file = lib.mkForce "/var/lib/postfix/postfixrelay.crt";
      smtp_tls_key_file = lib.mkForce "/var/lib/postfix/postfixrelay.key";
    };
  };

#  security.acme.certs."${toString(config.mailserver.fqdn)}" = {
#    webroot = "/var/lib/acme/.well-known/acme-challenge";
#    extraDomainNames = [ "${toString(config.mailserver.fqdn)}" ];
#    postRun = ''
#      systemctl reload dovecot2.service
#    '';
#  };
}

