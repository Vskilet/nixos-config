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
  boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only

  boot.supportedFilesystems = [ "zfs" ];
  services.zfs.autoSnapshot.enable = true;
  services.zfs.autoScrub.enable = true;

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
  environment.systemPackages = with pkgs; [
    wget vim tmux git
  ];
  nixpkgs.config.allowUnfree = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.zsh.enable = true;
  virtualisation.rkt.enable = true;
  users.extraGroups.rkt = { };
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
  # system.stateVersion = "18.03"; # Did you read the comment?YES
  system.autoUpgrade.enable = true;

}
