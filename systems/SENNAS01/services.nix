{ config, lib, pkgs, ... }:

{
  imports = [
    ../../services/mail
    ../../services/gitea
    ../../services/jitsi
    ../../services/mail
    ../../services/matrix
    ../../services/mautrix-whatsapp.nix
    ../../services/monitoring
    ../../services/nextcloud
    ../../services/nginx
    ../../services/peertube
    ../../services/unifi
  ];

  services.transmission = {
    enable = true;
    home = "/var/lib/transmission";
    port = 9091;
    openFirewall = true;
    settings = {
      download-dir = "/mnt/medias/downloads/";
      incomplete-dir = "/mnt/medias/downloads/.incomplete";
      incomplete-dir-enabled = true;
      rpc-bind-address = "127.0.0.1";
      rpc-host-whitelist = "*";
      rpc-whitelist-enabled = false;
      peer-port = 51413;
    };
  };
  systemd.services.transmission.serviceConfig.BindPaths = [ "/mnt/medias/" ];

  services.nfs.server = {
    enable = true;
    exports = ''
      /mnt/medias  192.168.1.0/24(ro,no_root_squash)
    '';
    statdPort = 4000;
    lockdPort = 4001;
    mountdPort = 4002;
  };

  services.fail2ban.enable = true;

  services.borgbackup.jobs = {
    senback01 = {
      paths = [
        "/var/certs"
        "/var/dkim"
        "/var/lib/gitea"
        "/var/lib/grafana"
        "/var/lib/matrix-synapse"
        "/var/lib/nextcloud/"
        "/var/lib/.zfs/snapshot/borgsnap/postgresql"
        "/var/sieve"
        "/var/vmail"
      ];
      repo = "/mnt/backups/borg";
      encryption = {
        mode = "repokey-blake2";
        passCommand = "cat /mnt/secrets/borgbackup_senback01_encryption_pass";
      };
      startAt = "weekly";
      prune.keep = {
        within = "1d";
        weekly = 4;
        monthly = 6;
      };
      preHook = "${pkgs.zfs}/bin/zfs snapshot senpool01/var/lib@borgsnap";
      postHook = ''
        ${pkgs.zfs}/bin/zfs destroy senpool01/var/lib@borgsnap
        if [[ $exitStatus == 0 ]]; then
          ${pkgs.rclone}/bin/rclone --config /mnt/secrets/rclone_senback01.conf sync -v $BORG_REPO ovh_backup:senback01
        fi
      '';
    };
  };

  networking.firewall.allowedTCPPorts = [
    111 2049 4000 4001 4002 # NFS
  ];
  networking.firewall.allowedUDPPorts = [
    111 2049 4000 4001 4002 # NFS
  ];
}

