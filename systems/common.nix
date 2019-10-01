{ config, pkgs, ... }:

{
  # Select internationalisation properties.
  i18n = {
     consoleKeyMap = "fr";
     defaultLocale = "fr_FR.UTF-8";
  };
  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  nixpkgs.overlays = [
    (import ../overlays/nvim.nix)
  ];
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
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
  programs.zsh.ohMyZsh.plugins = [ "docker" "git" "colored-man-pages" "command-not-found" "extract" ];
  programs.zsh.shellAliases = { ll="ls -alh --color=auto"; dpsa="docker ps -a"; vim="nvim"; };
  programs.zsh.promptInit = ''
    autoload -U promptinit
    promptinit
    prompt adam2
  '';

  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 15d";
}
