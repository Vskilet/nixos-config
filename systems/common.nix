{ config, pkgs, ... }:

{
  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # Select internationalisation properties.
  i18n.defaultLocale = "fr_FR.UTF-8";
  console.keyMap = "us";

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  nixpkgs.overlays = [
    (import ../overlays/nvim.nix)
  ];
  environment.systemPackages = with pkgs; [
    nix-index
    nix-prefetch-scripts
    nox

    nmap
    iperf
    inetutils
    dnsutils
    pciutils
    usbutils
    htop
    acpi
    ncdu

    nvim
    bat
    wget
    git
    tig
    jq
    tree

    lm_sensors
    pdftk
    ghostscript
  ];

  environment.variables = { EDITOR = "nvim"; };

  programs.tmux = {
    enable = true;
    clock24 = true;
    terminal = "screen-256color";
    newSession = true;
    historyLimit = 10000;
    extraConfig = ''
      bind-key a set-window-option synchronize-panes
      set-option -g mode-keys vi
      set -g mouse on
      unbind '|'
      bind-key % split-window -h
      unbind '"'
      bind-key - split-window -v
      unbind 'n'
      bind-key n new-window
    '';
  };

  users.defaultUserShell = pkgs.zsh;
  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    ohMyZsh = {
      enable = true;
      plugins = [ "git" "colored-man-pages" "command-not-found" "extract" ];
    };
    shellAliases = { ll="ls -alh --color=auto"; dpsa="docker ps -a"; };
    promptInit = ''
      autoload -U promptinit
      promptinit
      prompt adam2
    '';
  };

  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 15d";
}
