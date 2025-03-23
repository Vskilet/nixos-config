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
    acpi
    bat
    dnsutils
    ghostscript
    git
    htop
    inetutils
    iperf
    jq
    lm_sensors
    ncdu
    nix-index
    nix-prefetch-scripts
    nmap
    nvim
    pciutils
    pdftk
    tig
    tree
    usbutils
    wget
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
    autosuggestions.enable = true;
    enable = true;
    enableCompletion = true;
    histSize = 10000;
    syntaxHighlighting.enable = true;
    ohMyZsh = {
      enable = true;
      plugins = [ "colored-man-pages" "command-not-found" "extract" "git" "git-prompt" "tmux" "urltools" ];
    };
    shellAliases = {
      ll = "ls -alh --color=auto";
      dpsa = "docker ps -a";
    };
    promptInit = ''
      autoload -U promptinit
      promptinit
      prompt adam2
    '';
  };

  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 15d";
}
