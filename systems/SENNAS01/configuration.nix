{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ../common.nix
      ./hardware-configuration.nix
      ./users.nix
      ../../services/adguardhome
      ../../services/hass
      #../../services/k3s
      ../../services/kresus
      ../../services/mail
      ../../services/matrix
      ../../services/monitoring
      ../../services/nextcloud
      ../../services/nginx
      ../../services/peertube
      ../../services/unifi
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "zfs" ];
  services.zfs.autoSnapshot.enable = true;
  services.zfs.autoScrub.enable = true;

  documentation.nixos.enable = false;

  programs.zsh.loginShellInit = ''
    ZSH_TMUX_AUTOSTART="true"
    ZSH_TMUX_AUTOQUIT="false"
  '';

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      LoginGraceTime = 0;
    };
  };

  networking.hostName = "SENNAS01"; # Define your hostname.
  networking.hostId = "7e44e347";
  networking.useDHCP = false;
  networking.interfaces.eno1.useDHCP = true;
  networking.interfaces.eno2.useDHCP = true;
  networking.interfaces.eno3.useDHCP = true;
  networking.interfaces.eno4.useDHCP = true;

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  #environment.systemPackages = with pkgs; [
  #  borgbackup rclone kubectl
  #];

  virtualisation.docker.enable = true;
  virtualisation.docker.storageDriver = "zfs";
  boot.kernelModules = [ "overlay" ];

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_13;
  };

  services.nfs.server = {
    enable = true;
    exports = ''
      /mnt/medias  172.16.2.0/24(ro,no_root_squash)  172.16.1.0/24(ro,no_root_squash)
      /mnt/share  172.16.2.0/24(rw,sync,no_root_squash)  172.16.1.0/24(rw,sync,no_root_squash)
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
    1688
  ];
  networking.firewall.allowedUDPPorts = [
    111 2049 4000 4001 4002 # NFS
  ];
  networking.firewall.enable = true;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "18.03";
}
