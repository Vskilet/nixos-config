{ config, lib, pkgs, ... }:

{
  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usb_storage" "sd_mod" "sr_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ "i915" ];
  boot.kernelModules = [ "kvm-intel" "acpi_call" "tpm-rng" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];
  boot.extraModprobeConfig = ''
    options bbswitch use_acpi_to_detect_card_state=1
    options thinkpad_acpi force_load=1 fan_control=1
  '';
  boot.supportedFilesystems = [ "ntfs" ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices = {
    luks = {
      device = "/dev/disk/by-uuid/9174f611-814f-4aa4-a8be-df30f3b18787";
      preLVM = true;
      allowDiscards = true;
    };
  };

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/bf9dfa25-33a5-43ea-8faf-cc1ef39a27c3";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/B860-AA21";
      fsType = "vfat";
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/0bfe697f-e2b5-4f83-979e-31192cce865a";
      fsType = "ext4";
    };

  fileSystems."/mnt/medias" =
    { device = "SENNAS01:/mnt/medias";
      fsType = "nfs";
      options = ["x-systemd.automount" "noauto"];
    };
  fileSystems."/mnt/share" =
    { device = "SENNAS01:/mnt/share";
      fsType = "nfs";
      options = ["x-systemd.automount" "noauto"];
    };

  swapDevices = [ ];

  environment.variables = {
    VDPAU_DRIVER = lib.mkIf config.hardware.graphics.enable (lib.mkDefault "va_gl");
  };

  hardware.enableRedistributableFirmware = true;
  hardware.cpu.intel.updateMicrocode = true;
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
      intel-media-driver
    ];
  };

  nix.settings.max-jobs = lib.mkDefault 8;
  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";

}
