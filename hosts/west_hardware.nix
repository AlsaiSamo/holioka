{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.luks.devices = {
    cryptroot = {
      device = "/dev/disk/by-uuid/5d831ecd-ab23-4c69-8d22-1d70c0c6c306";
    };
  };
  boot.loader.grub = {
      enable = true;
      version = 2;
      enableCryptodisk = true;
      device = "/dev/sda";
  };

  boot.initrd.availableKernelModules = [ "ahci" "ohci_pci" "ehci_pci" "pata_atiixp" "xhci_pci" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  #this does not work
  #boot.initrd.postMountCommands = "chown -R imikoy:users /home/imikoy";

  #boot.tmpOnTmpfs = true;
  zramSwap.enable = true;

  fileSystems."/" =
    { device = "none";
      fsType = "tmpfs";
      options = [ "defaults" "size=2G" "mode=755" ];
    };

  fileSystems."/var/log" =
    { device = "nix_pool/local/log";
      fsType = "zfs";
    };

  fileSystems."/nix" =
    { device = "nix_pool/local/nix";
      fsType = "zfs";
    };

  fileSystems."/home" =
    { device = "nix_pool/local/home_tmp";
      fsType = "zfs";
    };

    boot.initrd.postDeviceCommands = lib.mkAfter ''
    zfs rollback -r nix_pool/local/home_tmp@blank
    '';

#  fileSystems."/home" =
#    { device = "nix_pool/safe/home";
#      fsType = "zfs";
#    };

#fileSystems."/home" = {
  #device = "none";
  #fsType = "tmpfs";
  #options = [ "defaults" "size=2G" "mode=755" "user" "users" ];
#};

  fileSystems."/state" =
    { device = "nix_pool/safe/state";
      fsType = "zfs";
      neededForBoot = true;
    };

  fileSystems."/state/secrets" =
    { device = "nix_pool/safe/secrets";
      fsType = "zfs";
      neededForBoot = true;
    };

  fileSystems."/etc/nixos" =
    { device = "/state/etc/nixos";
      fsType = "none";
      options = [ "bind" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/54AF-2F8E";
      fsType = "vfat";
    };

  swapDevices = [ ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp3s0.useDHCP = lib.mkDefault true;

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
