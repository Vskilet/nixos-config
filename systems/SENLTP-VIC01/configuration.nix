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
  networking.useDHCP = false;
  networking.interfaces.enp0s25.useDHCP = true;
  networking.interfaces.wlp3s0.useDHCP = true;
  hardware.bluetooth.enable = true;

  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  nixpkgs.config = {
    allowUnfree = false;
    allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "anydesk" "corefonts" "samsung-unified-linux-driver" "spotify" "spotify-unwrapped" "teams" "zoom"
    ];
  };
  environment.systemPackages = with pkgs; with gnome; with libsForQt5; [
    anydesk
    arandr
    evince
    filelight
    file-roller
    gnome-calculator
    gparted
    gwenview
    jitsi-meet-electron
    kate
    kdeconnect
    imagemagick
    libreoffice
    nautilus
    nextcloud-client
    pkgs.networkmanagerapplet
    okular
    pavucontrol
    spectacle
    texstudio
    (texlive.combine {
      inherit (texlive) scheme-small titling collection-langfrench cm-super xargs bigfoot lipsum;
    })
    virt-manager
    virt-viewer
    win-virtio
    zim

    chromium
    firefox
    signal-desktop
    element-desktop
    teams
    zoom-us

    audacity
    ffmpeg-full
    frei0r
    gimp
    inkscape
    kdenlive
    obs-studio
    openlpFull
    qlcplus
    spotify
    v4l-utils
    vlc

    appimage-run
    gnupg
    gopass
    jmtpfs
    mkpasswd
    nfs-utils
    parted
    youtube-dl
    xclip

    vitetris

    lxappearance
    breeze-icons
    breeze-gtk
    numix-gtk-theme
    numix-icon-theme
    qt5ct
  ];

  fonts.fonts = with pkgs; [
    corefonts
    dejavu_fonts
    freefont_ttf
  ];

  services.flatpak.enable = true;
  xdg.portal.enable = true;

  programs.wireshark.enable = true;
  programs.wireshark.package = pkgs.wireshark;

  programs.gnupg.agent = { enable = true; enableSSHSupport = true; };
  programs.browserpass.enable = true;

  programs.adb.enable = true;

  services.udev.packages = [ pkgs.qlcplus ];

  virtualisation.podman.enable = true;
  virtualisation.kvmgt.enable = true;
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      ovmf.enable = true;
      swtpm.enable = true;
      ovmf.package = pkgs.OVMFFull;
    };
    onBoot = "ignore";
    onShutdown = "shutdown";
  };
  environment.sessionVariables.LIBVIRT_DEFAULT_URI = [ "qemu:///system" ];

  services.tlp.enable = true;
  services.tlp.settings = {
    START_CHARGE_THRESH_BAT0 = 90;
    STOP_CHARGE_THRESH_BAT0 = 95;
    CPU_SCALING_GOVERNOR_ON_AC="performance";
    CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
    CPU_ENERGY_PERF_POLICY_ON_AC="performance";
    CPU_ENERGY_PERF_POLICY_ON_BAT="balance_power";
  };

  services.pcscd.enable = true;

  services.fstrim.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = with pkgs; [ hplip samsung-unified-linux-driver_1_00_37 ];

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  environment.variables = {
    QT_QPA_PLATFORMTHEME = "qt5ct";
    TERMINAL = "alacritty";
  };

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    layout = "fr,us";
    xkbVariant = ",intl";
    xkbOptions = "grp:win_space_toggle";
    libinput = {
      enable = true;
      touchpad.naturalScrolling = true;
    };
    displayManager.defaultSession = "none+i3";
    windowManager.i3 = {
      enable = true;
      package = pkgs.i3-gaps;
      extraPackages = with pkgs; [
        dmenu #application launcher most people use
        i3status # gives you the default i3 status bar
        i3lock #default i3 screen locker
        i3blocks #if you are planning on using i3blocks over i3status
        polybar xss-lock multilockscreen rofi i3-auto-layout
        rofi-pass rofi-calc rofi-power-menu
        alacritty
     ];
    };
    desktopManager = {
      xterm.enable = false;
    };
  };
  services.picom = {
    enable = true;
    backend = "glx";
    vSync = true;
  };

  programs.dconf.enable = true;
  services.gnome.evolution-data-server.enable = true;
  services.gnome.gnome-online-accounts.enable = true;
  services.gnome.gnome-keyring.enable = true;
  services.gvfs.enable = true;
  programs.evolution.enable = true;
  programs.light.enable = true;

  services.fprintd.enable = true;
  security.pam.services.login.fprintAuth = true;
  security.pam.services.xscreensaver.fprintAuth = true;

  #services.nginx.enable = true;
  #services.nginx.virtualHosts = {
  #  "localhost" = {
  #    locations."/" = {
  #     root = "/var/www/";
  #    };
  #    default = true;
  #  };
  #};

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    1716  # KDEConnect
    #80 443
  ];
  networking.firewall.allowedUDPPorts = [
    1716  # KDEConnect
  ];
  # Or disable the firewall altogether.
  networking.firewall.enable = true;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.03";
  system.autoUpgrade.enable = true;
}
