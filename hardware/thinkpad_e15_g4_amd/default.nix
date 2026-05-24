{
  config,
  lib,
  pkgs,
  modulesPath,
  volatile,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    volatile.west
  ];

  nix.settings.cores = 12;

  boot.kernelModules = [
    "kvm-amd"
    "amdgpu"
    "acpi_call"
  ];
  services.xserver.videoDrivers = [ "amdgpu" ];

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot = {
    enable = true;
    consoleMode = "auto";
  };
  zramSwap.enable = true;

  #NOTE: this also selects the kernel module to be 2.4.0.
  boot.zfs.package = pkgs.zfs_2_4;
  boot.kernelPackages = pkgs.linuxPackagesFor pkgs.linuxKernel.kernels.linux_zen;

  services.auto-epp.enable = true;
  # services.scx = {
  #   enable = true;
  #   package = pkgs.scx.rustscheds;
  #   scheduler = "scx_lavd";
  # };

  hardware.trackpoint.speed = 64;

  services.ananicy = {
    enable = true;
    package = pkgs.ananicy-cpp;
    rulesProvider = pkgs.ananicy-rules-cachyos;
  };

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

  services.libinput = lib.mkIf config.services.xserver.enable {
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
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
