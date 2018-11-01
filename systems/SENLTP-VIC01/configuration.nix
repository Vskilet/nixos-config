{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./users.nix
    ];
  nixpkgs.overlays = [
    (import ../../overlays/nvim.nix)
  ];

  networking.hostName = "SENLPT-VIC01"; # Define your hostname.
  networking.networkmanager.enable = true;  # Enables wireless support via wpa_supplicant.
  
  # Select internationalisation properties.
  i18n = {
     #consoleFont = "Lat2-Terminus16";
     consoleKeyMap = "fr";
     defaultLocale = "fr_FR.UTF-8";
  };
  # Set your time zone.
  time.timeZone = "Europe/Paris";
  
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    filezilla
    wineStaging
    winetricks
    transmission-remote-gtk
    appimage-run
    filelight 
    bat
    gopass
    xclip
    signal-desktop
    firefox
    audacity
    gnupg
    tdesktop
    nixnote2
    kdeplasma-addons
    ark
    kate
    kmail
    kdeconnect
    okular
    yakuake
    konversation
    gwenview
    kcalc
    (texlive.combine {
      inherit (texlive) scheme-small titling collection-langfrench cm-super;
    })
    imagemagick
    pciutils
    git
    tig
    gnome-breeze
    arc-theme
    materia-theme
    nvim
    libreoffice
    gimp
    vlc
  ];
  programs.wireshark.enable = true;
  programs.wireshark.package = pkgs.wireshark;

  programs.gnupg.agent = { enable = true; enableSSHSupport = true; };
  programs.browserpass.enable = true;
  
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

  environment.variables = { EDITOR = "nvim"; TERM = "konsole-256color"; };

  virtualisation.docker.enable = true;
  virtualisation.docker.storageDriver = "zfs";
  
  services.tlp.enable = true;
  services.sshd.enable = true; 
  services.pcscd.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.hplip ];

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
}
