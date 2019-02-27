{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./users.nix
      ../common.nix
    ];

  networking.hostName = "SENLPT-VIC01"; # Define your hostname.
  networking.networkmanager.enable = true;  # Enables wireless support via wpa_supplicant.

  boot.initrd.network.enable = true;
  boot.initrd.network.ssh.enable = true;
  boot.initrd.network.ssh.authorizedKeys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC1r2ZzVnOlmoNoLgrc3+Lx7whO8mzcwUf2p9DiYAVg2zo2zbfubLVG1BAgFDe7y+2HwJIbGDDMNUaT+FAsv0mHRlfdUMXXF3nVsFPWGovo1ks31O5zUI9IE3qFU5AJ7SPICS4lQYox1o594iS1OcwJ7Iu6pjEQRRG1OLVYSILJ994vtGsDxfz1CZ8b7u9oSwHz0E4pdy6epkFSE/+9WsZl+ziDMigYZfubjzUCzMy2uT5Z6t+r6bW6mcxnmYax/YmrRvL/dTeDE64Qf7nugjB0XOKUOKCPN5dtqYRx0fN9aDSRf4ubmyVaYeKudm9vttGHXjSPVWAvow+jUDOq2cGr victor@sene.ovh"
  ];

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; with kdeApplications; [
    ark
    kate
    kmail
    kdeconnect
    okular
    konversation
    kcalc
    kdeplasma-addons
    akonadiconsole
    spectacle
    yakuake

    gwenview
    imagemagick
    gnome-breeze
    arc-theme
    materia-theme
    wine-staging
    wineWowPackages.staging
    winetricks

    firefox
    chromium
    filezilla
    transmission-remote-gtk
    filelight
    signal-desktop
    tdesktop

    (texlive.combine {
      inherit (texlive) scheme-small titling collection-langfrench cm-super;
    })
    nixnote2
    libreoffice
    gimp
    vlc

    audacity
    qlcplus
    nextcloud-client
    spotify
    teamviewer

    appimage-run
    gnupg
    gopass
    xclip

    vitetris
  ];
  programs.wireshark.enable = true;
  programs.wireshark.package = pkgs.wireshark;

  programs.gnupg.agent = { enable = true; enableSSHSupport = true; };
  programs.browserpass.enable = true;

  services.xrdp.enable = true;
  services.xrdp.defaultWindowManager = "startkde";

  services.udev.packages = [ pkgs.qlcplus ];

  environment.variables = { TERM = "konsole-256color"; };

  virtualisation.docker.enable = true;
  virtualisation.virtualbox.host.enable = true;
  virtualisation.virtualbox.host.enableExtensionPack = true;

  services.tlp.enable = true;
  services.tlp.extraConfig = ''
    DEVICES_TO_DISABLE_ON_STARTUP="bluetooth"
    START_CHARGE_THRESH_BAT0=85
    STOP_CHARGE_THRESH_BAT0=90
    CPU_SCALING_GOVERNOR_ON_BAT=powersave
    ENERGY_PERF_POLICY_ON_BAT=powersave
  '';

  services.pcscd.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = with pkgs; [ hplip samsung-unified-linux-driver_1_00_37 ];

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "fr";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable touchpad support.
  services.xserver.libinput.enable = true;
  services.xserver.libinput.naturalScrolling = true;

  # Enable the KDE Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  services.fprintd.enable = true;
  security.pam.services.login.fprintAuth = true;
  security.pam.services.xscreensaver.fprintAuth = true;

  # Open ports in the firewall.
  #networking.firewall.allowedTCPPorts = [ ];
  #networking.firewall.allowedUDPPorts = [ ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "18.09";
  system.autoUpgrade.enable = true;
}
