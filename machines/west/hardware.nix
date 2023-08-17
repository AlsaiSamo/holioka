{ config, lib, pkgs, modulesPath, ... }: {
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  hardware.nvidia = {
    #Offload is enabled in nixos-hardware module
    #FIX: causes issues. See notes.
    #prime.reverseSync.enable = true;
    prime.sync.enable = lib.mkForce true;
    prime.offload.enable = lib.mkForce false;
    modesetting.enable = true;
    powerManagement.enable = true;
    #will this lead to issues?
    #powerManagement.finegrained = true;
    open = false;
  };

  swapDevices = [{ device = "/dev/disk/by-uuid/cf9e173b-197a-43fa-836e-e1cb9a563437"; }];

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/8933-C2AD";
    fsType = "vfat";
  };

  boot.initrd.luks.devices = {
    cryptroot = {
      device = "/dev/disk/by-uuid/9ea8f9f0-585f-41c4-9aab-6091a7b6c145";
    };
  };

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    enableCryptodisk = true;
    device = "nodev";
  };
  zramSwap.enable = true;

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "ehci_pci"
    "nvme"
    "usbhid"
    "usb_storage"
    "sd_mod"
    "rtsx_pci_sdmmc"
  ];
  boot.initrd.kernelModules = [ ];
#TODO: amd drivers will be missing, I believe. So, I will need to see if this causes issues.
  #boot.kernelModules = [ "kvm-amd" "amdgpu" "acpi_call" ];
  #boot.extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];
  #boot.kernelParams = [ "iommu=soft" "i8042.nomux=1" "i8042.reset" ];

  services.xserver.libinput = lib.mkIf config.services.xserver.enable {
    enable = true;
    touchpad = {
      naturalScrolling = true;
      disableWhileTyping = true;
    };
  };

  services.tlp = {
    enable = true;
    settings = {
      #keyboard
      USB_DENYLIST = "8114:5981";
      # CPU_SCALING_GOVERNOR_ON_AC = "performance";
      # CPU_SCALING_GOVERNOR_ON_BAT = "schedutil";
      # CPU_MAX_PERF_ON_AC = 100;
      # CPU_MAX_PERF_ON_BAT = 75;
      # START_CHARGE_THRESH_BAT1 = 80;
      # STOP_CHARGE_THRESH_BAT1 = 85;
      # START_CHARGE_THRESH_BAT0 = 75;
      # STOP_CHARGE_THRESH_BAT0 = 80;
    };
  };

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp1s0f0.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp3s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;
}
