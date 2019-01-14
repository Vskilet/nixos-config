{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./users.nix
      ./services.nix
    ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.loader.grub.device = "/dev/disk/by-id/ata-SAMSUNG_SP2504C_S09QJ10L806216"; # or "nodev" for efi only

  boot.supportedFilesystems = [ "zfs" ];
  services.zfs.autoSnapshot.enable = true;
  services.zfs.autoScrub.enable = true;

  boot.initrd.network.ssh.enable = true;
  boot.initrd.network.ssh.authorizedKeys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC1r2ZzVnOlmoNoLgrc3+Lx7whO8mzcwUf2p9DiYAVg2zo2zbfubLVG1BAgFDe7y+2HwJIbGDDMNUaT+FAsv0mHRlfdUMXXF3nVsFPWGovo1ks31O5zUI9IE3qFU5AJ7SPICS4lQYox1o594iS1OcwJ7Iu6pjEQRRG1OLVYSILJ994vtGsDxfz1CZ8b7u9oSwHz0E4pdy6epkFSE/+9WsZl+ziDMigYZfubjzUCzMy2uT5Z6t+r6bW6mcxnmYax/YmrRvL/dTeDE64Qf7nugjB0XOKUOKCPN5dtqYRx0fN9aDSRf4ubmyVaYeKudm9vttGHXjSPVWAvow+jUDOq2cGr victor@sene.ovh" ];

  networking.hostName = "SENNAS01"; # Define your hostname.
  networking.hostId = "7e44e347";

  # Select internationalisation properties.
  i18n = {
  #   consoleFont = "Lat2-Terminus16";
     consoleKeyMap = "fr";
     defaultLocale = "fr_FR.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  nixpkgs.overlays = [
    (import ../../overlays/riot-web.nix)
    (import ../../overlays/nvim.nix)
    (import ../../overlays/unstable-pkgs.nix)
  ];
  environment.systemPackages = with pkgs; [
    wget nvim tmux git htop dnsutils nmap busybox lm_sensors borgbackup rclone tig kubectl
  ];
  nixpkgs.config.allowUnfree = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  users.defaultUserShell = pkgs.zsh;
  programs.zsh.enable = true;
  programs.zsh.autosuggestions.enable = true;
  programs.zsh.enableCompletion = true;
  programs.zsh.syntaxHighlighting.enable = true;
  programs.zsh.ohMyZsh.enable = true;
  programs.zsh.ohMyZsh.plugins = [ "docker" "git" "colored-man-pages" "command-not-found" "extract" ];
  programs.zsh.shellAliases = { ll="ls -alh --color=auto"; dpsa="docker ps -a"; };
  programs.zsh.promptInit = ''
    autoload -U promptinit
    promptinit
    prompt adam2
  '';

  environment.variables = { EDITOR = "nvim"; };

  virtualisation.docker.enable = true;
  virtualisation.docker.storageDriver = "zfs";
  boot.kernelModules = [ "overlay" ];
  # programs.bash.enableCompletion = true;
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.permitRootLogin = "no";

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ ];
  networking.firewall.allowedUDPPorts = [ ];
  # Or disable the firewall altogether.
  networking.firewall.enable = true;

  security.sudo.wheelNeedsPassword = false;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.

  system.stateVersion = "18.03";
  system.autoUpgrade.enable = true;
  systemd.services.nixos-upgrade.path = with pkgs; [  gnutar xz.bin gzip config.nix.package.out ];
  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 15d";
}
