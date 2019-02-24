{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./users.nix
    ];

  networking.hostName = "asus-amarie"; # Define your hostname.
  networking.networkmanager.enable = true;  # Enables wireless support via wpa_supplicant.

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only

  # Select internationalisation properties.
  i18n = {
     consoleKeyMap = "fr";
     defaultLocale = "fr_FR.UTF-8";
  };
  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; with kdeApplications; [
    dnsutils
    nmap
    pciutils
    usbutils
    htop
    acpi
    iperf

    wget
    tmux
    neovim
    git
    tig
    tmate

    lm_sensors
    pdftk
    ghostscript

    ark
    kate
    okular
    akonadiconsole
    spectacle

    gwenview
    imagemagick
    gnome-breeze
    arc-theme
    materia-theme
    wine-staging
    wineWowPackages.staging
    winetricks

    firefox
    filelight
    libreoffice
    gimp
    vlc
    appimage-run

    chessx
    superTux
  ];

  users.defaultUserShell = pkgs.zsh;
  programs.zsh.enable = true;
  programs.zsh.autosuggestions.enable = true;
  programs.zsh.enableCompletion = true;
  programs.zsh.syntaxHighlighting.enable = true;
  programs.zsh.ohMyZsh.enable = true;
  programs.zsh.ohMyZsh.plugins = [ "git" "colored-man-pages" "command-not-found" "extract" "nix" ];
  programs.zsh.shellAliases = { ll="ls -alh --color=auto"; vim="nvim"; };
  programs.zsh.promptInit = ''
    autoload -U promptinit
    promptinit
    prompt adam2
  '';

  services.tlp.enable = true;
  services.tlp.extraConfig = ''
    DEVICES_TO_DISABLE_ON_STARTUP="bluetooth"
    START_CHARGE_THRESH_BAT0=85
    STOP_CHARGE_THRESH_BAT0=90
    CPU_SCALING_GOVERNOR_ON_BAT=powersave
    ENERGY_PERF_POLICY_ON_BAT=powersave
  '';

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.permitRootLogin = "no";

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = with pkgs; [ hplip ];

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

  services.xserver.desktopManager.mate.enable = true;

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
  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 15d";
}
