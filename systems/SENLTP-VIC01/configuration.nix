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

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  nixpkgs.config = {
    allowUnfree = true;
    firefox.enablePlasmaBrowserIntegration = true;
  };
  environment.systemPackages = with pkgs; with gnome; with libsForQt5; [
    anydesk
    mkpasswd
    jitsi-meet-electron
    parted
    nfsUtils

    obs-studio
    kdenlive
    ffmpeg-full
    frei0r
    v4l-utils

    gparted
    gwenview
    imagemagick
    gnome-breeze
    materia-theme
    wineWowPackages.unstable
    (winetricks.override {
      wine = wineWowPackages.unstable;
    })

    firefox
    chromium
    filezilla
    transmission-remote-gtk
    filelight
    signal-desktop
    element-desktop
    teams
    zoom-us

    texstudio
    (texlive.combine {
      inherit (texlive) scheme-small titling collection-langfrench cm-super xargs bigfoot lipsum;
    })
    nixnote2
    zim
    libreoffice
    gimp
    vlc
    molotov

    audacity
    qlcplus
    nextcloud-client
    spotify

    appimage-run
    youtube-dl
    gnupg
    gopass
    xclip
    jmtpfs

    vitetris

    lxappearance
    breeze-icons
    gnome-breeze
    numix-gtk-theme
    numix-icon-theme
    qt5ct
    #materia-theme
    #adwaita-icon-theme
  ];

  fonts.fonts = with pkgs; [
    corefonts
    dejavu_fonts
    freefont_ttf
  ];

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
    qemuOvmf = true;
    #qemuRunAsRoot = false;
    onBoot = "ignore";
    onShutdown = "shutdown";
  };

  services.tlp.enable = true;
  services.tlp.settings = {
    DEVICES_TO_DISABLE_ON_STARTUP = "bluetooth";
    START_CHARGE_THRESH_BAT0 = 85;
    STOP_CHARGE_THRESH_BAT0 = 95;
    CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
    ENERGY_PERF_POLICY_ON_BAT = "powersave";
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
        polybar multilockscreen rofi i3-auto-layout
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
  programs.evolution.enable = true;
  programs.light.enable = true;

  services.fprintd.enable = true;
  security.pam.services.login.fprintAuth = true;
  security.pam.services.xscreensaver.fprintAuth = true;
  # Workaround nfsutils - Issue https://github.com/NixOS/nixpkgs/issues/24913
  security.wrappers."mnt-medias.mount".source = "${pkgs.nfs-utils.out}/bin/mount.nfs";

  # Open ports in the firewall.
  #networking.firewall.allowedTCPPorts = [ ];
  #networking.firewall.allowedUDPPorts = [ ];
  # Or disable the firewall altogether.
  networking.firewall.enable = true;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.03";
  system.autoUpgrade.enable = true;
}
