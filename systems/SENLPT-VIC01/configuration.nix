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
      "anydesk" "corefonts" "samsung-unified-linux-driver" "spotify" "spotify-unwrapped"
    ];
  };
  environment.systemPackages = with pkgs; with gnome; with libsForQt5; [
    anydesk
    appimage-run
    arandr
    audacity
    evince
    ffmpeg-full
    file-roller
    firefox
    frei0r
    gimp
    gnome-disk-utility
    gnupg
    gopass
    imagemagick
    inkscape
    jmtpfs
    kate
    kdeconnect-kde
    kdenlive
    kubectl
    libreoffice
    mkpasswd
    cinnamon.nemo
    nextcloud-client
    nfs-utils
    obs-studio
    okular
    #openlpFull
    parted
    pavucontrol
    pkgs.networkmanagerapplet
    pkgs.shotwell
    qlcplus
    spectacle
    spotify
    v4l-utils
    virt-manager
    virt-viewer
    vitetris
    vlc
    win-virtio
    wineWowPackages.staging
    winetricks
    woeusb
    xclip
    xcolor
    yt-dlp
    zim

    texstudio
    (texlive.combine {
      inherit (texlive) scheme-small titling collection-langfrench cm-super xargs bigfoot lipsum;
    })

    #breeze-gtk
    breeze-icons
    numix-gtk-theme
    numix-icon-theme
    yaru-theme
    lxappearance
    qt5ct
  ];

  fonts.fonts = with pkgs; [
    corefonts
    dejavu_fonts
    freefont_ttf
  ];

  services.flatpak.enable = true;
  xdg.portal.enable = true;
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTR{idVendor}=="1edb", ATTR{idProduct}=="be55", MODE="0666"
  '';

  programs.wireshark.enable = true;
  programs.wireshark.package = pkgs.wireshark;

  programs.gnupg.agent = { enable = true; enableSSHSupport = true; };
  programs.browserpass.enable = true;

  programs.adb.enable = true;
  programs.java.enable = true;

  services.udev.packages = [ pkgs.qlcplus ];

  virtualisation.podman.enable = true;
  virtualisation.kvmgt.enable = true;
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
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
      configFile = /etc/nixos/misc/i3.config;
      extraPackages = with pkgs; [
        dmenu #application launcher most people use
        i3status # gives you the default i3 status bar
        i3lock #default i3 screen locker
        i3blocks #if you are planning on using i3blocks over i3status
        polybar xss-lock multilockscreen rofi i3-auto-layout
        rofi-pass rofi-power-menu
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
  services.autorandr = {
    enable = true;
    profiles = {
      "desk" = {
        fingerprint = {
          eDP-1 = "00ffffffffffff0030e4fc030000000000170104951f11780aa3e59659558e271f505400000001010101010101010101010101010101482640a460841a303020250035ae10000019000000000000000000000000000000000000000000fe004c4720446973706c61790a2020000000fe004c503134305744322d54504231002a";
          HDMI-1 = "00ffffffffffff0030aeab6101010101081d010380331d782e27b5a4574c9f260f5054bdcf00714f8180818c9500b300d1c001010101023a801871382d40582c4500fd1e1100001e000000ff0056333033334c544d0a20202020000000fd00324b1e5311000a202020202020000000fc004c454e20543233692d31300a20017902031ef14b010203040514111213901f230907078301000065030c001000011d007251d01e206e285500fd1e1100001e8c0ad08a20e02d10103e9600fd1e110000188c0ad090204031200c405500fd1e110000180000000000000000000000000000000000000000000000000000000000000000000000000000000000000052";
          VGA-1 = "00ffffffffffff0030aeab6157464e460e1e01036c331d782e27b5a4574c9f260f5054bdcf00714f8180818c9500b300d1c001010101023a801871382d40582c4500fd1e1100001e000000ff0056333035464e46570a20202020000000fd00324b1e5315000a202020202020000000fc004c454e20543233692d31300a200043";
        };
        config = {
          eDP-1 = {
            enable = true;
            mode = "1600x900";
            position = "0x0";
            rate = "60.00";
            crtc = 1;
            rotate = "normal";
          };
          HDMI-1 = {
            enable = true;
            mode = "1920x1080";
            position = "1600x0";
            rate = "60.00";
            crtc = 0;
            primary = true;
            rotate = "normal";
          };
          VGA-1 = {
            enable = true;
            mode = "1920x1080";
            position = "3520x0";
            rate = "60.00";
            crtc = 2;
            rotate = "normal";
          };
        };
        hooks.postswitch = {
          "update-lockscreen" = "${pkgs.multilockscreen}/bin/multilockscreen --blur 1.0 -u /home/victor/Images/Wallpapers/gears.png";
        };
      };
      "laptop" = {
        fingerprint = {
          eDP-1 = "00ffffffffffff0030e4fc030000000000170104951f11780aa3e59659558e271f505400000001010101010101010101010101010101482640a460841a303020250035ae10000019000000000000000000000000000000000000000000fe004c4720446973706c61790a2020000000fe004c503134305744322d54504231002a";
        };
        config = {
          eDP-1 = {
            enable = true;
            mode = "1600x900";
            position = "0x0";
            rate = "60.00";
            crtc = 0;
            rotate = "normal";
          };
        };
        hooks.postswitch = {
          "update-lockscreen" = "${pkgs.multilockscreen}/bin/multilockscreen --blur 1.0 -u /home/victor/Images/Wallpapers/gears.png";
        };
      };
      "tele" = {
        fingerprint = {
          eDP-1 = "00ffffffffffff0030e4fc030000000000170104951f11780aa3e59659558e271f505400000001010101010101010101010101010101482640a460841a303020250035ae10000019000000000000000000000000000000000000000000fe004c4720446973706c61790a2020000000fe004c503134305744322d54504231002a";
          HDMI-1 = "00ffffffffffff004c2d670b3336333002190103803c22782a9791a556549d250e5054bfef80714f81c0810081809500a9c0b3000101023a801871382d40582c450056502100001e011d007251d01e206e28550056502100001e000000fd00324b1e5111000a202020202020000000fc00533237443339300a2020202020010302031af14690041f130312230907078301000066030c00100080011d00bc52d01e20b828554056502100001e8c0ad090204031200c4055005650210000188c0ad08a20e02d10103e9600565021000018000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000061";
        };
        config = {
          eDP-1 = {
            enable = true;
            mode = "1600x900";
            position = "1920x0";
            rate = "60.00";
            crtc = 1;
            rotate = "normal";
          };
          HDMI-1 = {
            enable = true;
            mode = "1920x1080";
            position = "0x0";
            rate = "60.00";
            crtc = 0;
            primary = true;
            rotate = "normal";
          };
        };
        hooks.postswitch = {
          "update-lockscreen" = "${pkgs.multilockscreen}/bin/multilockscreen --blur 1.0 -u /home/victor/Images/Wallpapers/gears.png";
        };
      };
    };
  };
  environment.etc."i3status.conf".source = /etc/nixos/misc/i3status.config;
  environment.etc."alacritty.yml".source = /etc/nixos/misc/alacritty.yml;

  programs.dconf.enable = true;
  services.gnome.evolution-data-server.enable = true;
  services.gnome.gnome-online-accounts.enable = true;
  services.gnome.gnome-keyring.enable = true;
  services.gnome.sushi.enable = true;
  services.gvfs.enable = true;
  services.blueman.enable = true;
  programs.evolution.enable = true;
  programs.light.enable = true;

  services.fprintd.enable = true;
  security.pam.services.login.fprintAuth = true;
  security.pam.services.xscreensaver.fprintAuth = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    1716  # KDEConnect
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
  system.stateVersion = "22.11";
  system.autoUpgrade.enable = true;
}
