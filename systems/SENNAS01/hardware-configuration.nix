# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "ehci_pci" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" "ipmi_si" "acpi_ipmi" ];
  boot.extraModulePackages = [ ];

  hardware.enableRedistributableFirmware = true;
  hardware.cpu.intel.updateMicrocode = true;

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/3dacf33b-6940-495b-a588-cea2b4b98a28";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/AA83-DFB9";
      fsType = "vfat";
    };

  fileSystems."/mnt/medias" =
    { device = "senpool01/medias";
      fsType = "zfs";
    };

  fileSystems."/mnt/share" =
    { device = "senpool01/share";
      fsType = "zfs";
    };

  fileSystems."/mnt/backups" =
    { device = "/dev/disk/by-uuid/3d4d5f8e-9cc6-44d0-a420-d2f153a02319";
      fsType = "ext4";
      options  = [ "nofail" ];
    };

  fileSystems."/mnt/secrets" =
    { device = "senpool01/secrets";
      fsType = "zfs";
      options  = [ "nofail" ];
    };


  fileSystems."/var/certs" =
    { device = "senpool01/var/certs";
      fsType = "zfs";
    };

  fileSystems."/var/db" =
    { device = "senpool01/var/db";
      fsType = "zfs";
    };

  fileSystems."/var/dkim" =
    { device = "senpool01/var/dkim";
      fsType = "zfs";
    };

  fileSystems."/var/lib" =
    { device = "senpool01/var/lib";
      fsType = "zfs";
    };

  fileSystems."/var/lib/docker" =
    { device = "senpool01/var/lib/docker";
      fsType = "zfs";
    };

  fileSystems."/var/lib/gitea" =
    { device = "senpool01/var/lib/gitea";
      fsType = "zfs";
    };

  fileSystems."/var/lib/grafana" =
    { device = "senpool01/var/lib/grafana";
      fsType = "zfs";
    };

  fileSystems."/var/lib/kresus" =
    { device = "senpool01/var/lib/kresus";
      fsType = "zfs";
    };

  fileSystems."/var/lib/matrix-synapse" =
    { device = "senpool01/var/lib/matrix-synapse";
      fsType = "zfs";
    };

  fileSystems."/var/lib/mautrix-signal" =
    { device = "senpool01/var/lib/mautrix-signal";
      fsType = "zfs";
    };

  fileSystems."/var/lib/mautrix-whatsapp" =
    { device = "senpool01/var/lib/mautrix-whatsapp";
      fsType = "zfs";
    };

  fileSystems."/var/lib/nextcloud" =
    { device = "senpool01/var/lib/nextcloud";
      fsType = "zfs";
    };

  fileSystems."/var/lib/opendkim" =
    { device = "senpool01/var/lib/opendkim";
      fsType = "zfs";
    };

  fileSystems."/var/lib/peertube" =
    { device = "senpool01/var/lib/peertube";
      fsType = "zfs";
    };

  fileSystems."/var/lib/postgresql" =
    { device = "senpool01/var/lib/postgresql";
      fsType = "zfs";
    };

  fileSystems."/var/lib/unifi" =
    { device = "senpool01/var/lib/unifi";
      fsType = "zfs";
    };

  fileSystems."/var/sieve" =
    { device = "senpool01/var/sieve";
      fsType = "zfs";
    };

  fileSystems."/var/vmail" =
    { device = "senpool01/var/vmail";
      fsType = "zfs";
    };

  fileSystems."/var/www" =
    { device = "senpool01/var/www";
      fsType = "zfs";
    };


   swapDevices = [ {
     device = "/var/swapfile";
     size = 8096;
    } ];

  nix.settings.max-jobs = lib.mkDefault 4;
}
