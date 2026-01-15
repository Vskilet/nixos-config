{ config, lib, pkgs, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../common.nix
      ../../users/victor
      ../../desktop
    ];

  networking.hostName = "SENLPT-VIC14"; # Define your hostname.
  networking.networkmanager.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.useDHCP = false;
  networking.interfaces.enp1s0f0.useDHCP = true;
  networking.interfaces.wlp2s0.useDHCP = true;
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
      };
    };
  };
  services.blueman.enable = true;

  environment.systemPackages = with pkgs; with kdePackages; [
    anydesk
    appimage-run
    audacity
    chromium
    #davinci-resolve
    ffmpeg-full
    file-roller
    fractal
    frei0r
    gimp
    glaxnimate
    gnome-disk-utility
    gnupg
    go
    gopls
    gopass
    handbrake
    imagemagick
    inkscape
    jmtpfs
    kdeconnect-kde
    kdenlive
    kubectl
    libreoffice
    mkpasswd
    mpv
    nemo
    nextcloud-client
    nfs-utils
    obs-studio
    okular
    onedrivegui
    openswitcher
    parted
    pavucontrol
    pkgs.shotwell
    python3
    qlcplus
    rpi-imager
    spotify
    v4l-utils
    virt-manager
    virt-viewer
    virtiofsd
    vlc
    virtio-win
    vscode
    wineWowPackages.staging
    winetricks
    woeusb
    yt-dlp

    texstudio
    (texlive.combine {
      inherit (texlive) scheme-small titling collection-langfrench cm-super xargs bigfoot lipsum;
    })
  ];

  fonts.packages = with pkgs; [
    corefonts
    dejavu_fonts
    freefont_ttf
    raleway
  ];

  #services.onedrive.enable = true;

  services.flatpak.enable = true;

  programs.gnupg.agent = { enable = true; enableSSHSupport = true; };
  programs.browserpass.enable = true;
  programs.firefox.enable = true;

  programs.adb.enable = true;
  programs.java.enable = true;

  services.udev = {
    packages = [ pkgs.qlcplus ];
    extraRules = ''
      SUBSYSTEM=="usb", ATTR{idVendor}=="1edb", ATTR{idProduct}=="be55", MODE="0666"
    '';
  };

  virtualisation.podman.enable = true;
  virtualisation.kvmgt.enable = true;
  virtualisation.libvirtd = {
    enable = true;
    allowedBridges = [ "enp1s0f0" "wlp2s0" ];
    onBoot = "ignore";
    onShutdown = "shutdown";
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
    };
  };
  programs.virt-manager.enable = true;

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

  programs.dconf.enable = true;
  services.gvfs.enable = true;
  #services.gnome.sushi.enable = true;

  services.accounts-daemon.enable = true;
  services.gnome.gnome-online-accounts.enable = true;
  services.gnome.gnome-keyring.enable = true;
  services.gnome.evolution-data-server.enable = true;
  programs.evolution = {
    enable = true;
    plugins = [ pkgs.evolution-ews ];
  };
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
  system.stateVersion = "25.05";
  system.autoUpgrade.enable = true;
}
