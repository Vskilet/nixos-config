{ config, lib, pkgs, ... }:

{
  imports =
    [ 
      <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ];
  
  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usb_storage" "sd_mod" "sr_mod" "rtsx_pci_sdmmc" ];  
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices = [
    {
      name = "luks";
      device = "/dev/disk/by-uuid/9174f611-814f-4aa4-a8be-df30f3b18787";
      preLVM = true;
      allowDiscards = true;
    }
  ];

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

  swapDevices = [ ];


  hardware.enableRedistributableFirmware = true;
  hardware.u2f.enable = true;

  nix.maxJobs = lib.mkDefault 8;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

}
