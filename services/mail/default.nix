{ lib, config, pkgs, ... }:

with lib;

{
  mailserver = {
    enable = true;
    fqdn = "mail.sene.ovh";
    domains = [ "sene.ovh" "stech.ovh" ];
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
        sieveScript = ''
          require "subaddress";
          require "fileinto";

          if header :contains "X-Spam" "YES" {
              fileinto "Junk";
              stop;
          }
        '';
      };
      "constance@sene.ovh" = {
        hashedPassword = "$6$wGIPnWzZqfJD0.l$HpxYitiTsIWQVFoJOnJax5ZEJXucdhMsfc8vKgNzX7QfQQ/CSIwcozXfB49cqEXRivktd3aKcop1k7tCo840w/";
        aliases = [
          "constance.prowin@sene.ovh"
        ];
      };
      "prunille@sene.ovh" = {
        hashedPassword = "$6$R7HuHy5.IetwgIo4$onlqGxu.DINEjXkqUv.GGYISsff2RKR69OCFB/ETuZxKM3vnDJX4BzHqAvKyhjRLsGwZ6p6geLPtUr4WIB2Mq.";
      };
      "eline@sene.ovh" = {
        hashedPassword = "$6$SH/Lk4f3tGsPpeEP$j2jTkANTyJF2ixzLmNPvzPfZJsbK.p045zvlLVJjhnSvZHn1XkB7xqM.tNZS1gd1RUOKM0CBfcQzsWzfg8N.A0";
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
      "nextcloud@sene.ovh" = {
        hashedPassword = "$2b$05$nJdLEnGj8AOBXz4/PZ1Rked1dbr7Tb6QYTfy8q2UhYQhaSJ8x6YY6";
        sendOnly = true;
      };

    };

    # Certificate setup
    certificateScheme = "acme-nginx";

    # Enable IMAP and POP3
    enableImap = false;
    enablePop3 = false;
    enableImapSsl = true;
    enablePop3Ssl = false;
    #enableSubmission = false;
    enableSubmissionSsl = true;

    # Enable the ManageSieve protocol
    enableManageSieve = true;

    stateVersion = 3;
    virusScanning = false;
  };
}

