{ config, pkgs, ... }:

{
  # Select internationalisation properties.
  i18n = {
     consoleKeyMap = "fr";
     defaultLocale = "fr_FR.UTF-8";
  };
  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.permitRootLogin = "no";

  boot.initrd.network.ssh.enable = true;
  boot.initrd.network.ssh.authorizedKeys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC1r2ZzVnOlmoNoLgrc3+Lx7whO8mzcwUf2p9DiYAVg2zo2zbfubLVG1BAgFDe7y+2HwJIbGDDMNUaT+FAsv0mHRlfdUMXXF3nVsFPWGovo1ks31O5zUI9IE3qFU5AJ7SPICS4lQYox1o594iS1OcwJ7Iu6pjEQRRG1OLVYSILJ994vtGsDxfz1CZ8b7u9oSwHz0E4pdy6epkFSE/+9WsZl+ziDMigYZfubjzUCzMy2uT5Z6t+r6bW6mcxnmYax/YmrRvL/dTeDE64Qf7nugjB0XOKUOKCPN5dtqYRx0fN9aDSRf4ubmyVaYeKudm9vttGHXjSPVWAvow+jUDOq2cGr victor@sene.ovh"
  ];


  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  nixpkgs.overlays = [
    (import ../overlays/nvim.nix)
  ];
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    busybox
    dnsutils
    nmap
    pciutils
    usbutils
    htop
    acpi
    iperf
    net_snmp
    telnet

    nvim
    bat
    wget
    tmux
    git
    tig

    lm_sensors
    pdftk
    ghostscript
  ];

  environment.variables = { EDITOR = "nvim"; };

  users.defaultUserShell = pkgs.zsh;
  programs.zsh.enable = true;
  programs.zsh.autosuggestions.enable = true;
  programs.zsh.enableCompletion = true;
  programs.zsh.syntaxHighlighting.enable = true;
  programs.zsh.ohMyZsh.enable = true;
  programs.zsh.ohMyZsh.plugins = [ "docker" "git" "colored-man-pages" "command-not-found" "extract" "nix" ];
  programs.zsh.shellAliases = { ll="ls -alh --color=auto"; dpsa="docker ps -a"; vim="nvim"; };
  programs.zsh.promptInit = ''
    autoload -U promptinit
    promptinit
    prompt adam2
  '';

  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 15d";
}
