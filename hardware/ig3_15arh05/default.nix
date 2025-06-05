{
  config,
  lib,
  pkgs,
  modulesPath,
  volatile,
  ...
}: {
  imports = [(modulesPath + "/installer/scan/not-detected.nix") volatile.west];

  #TODO: optimise for high memory pressure (zramSwap, related options)

  nix.settings.cores = 6;

  #default, needs to be overridable
  # hardware.nvidia = {
  #   #Offload is enabled in nixos-hardware module
  #   #FIX: causes issues.
  #   #prime.reverseSync.enable = true;
  #   prime.sync.enable = true;
  #   prime.offload.enable = false;
  #   modesetting.enable = true;
  #   powerManagement.enable = true;
  #   #will this lead to issues?
  #   #powerManagement.finegrained = true;
  #   open = false;
  # };

  # NOTE: one-display only!
  boot.blacklistedKernelModules = ["nouveau" "nvidia" "nvidia_drm" "nvidia_modeset"];
  boot.kernelModules = ["kvm-amd" "amdgpu" "acpi_call"];
  services.xserver.videoDrivers = ["amdgpu"];

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    enableCryptodisk = true;
    device = "nodev";
  };
  zramSwap.enable = true;

  boot.kernelPackages = pkgs.linuxPackagesFor pkgs.linuxKernel.kernels.linux_zen;
  #TODO: services.scx.scheduler = "scx_lavd"; services.scx.enable = true;

  #TODO: replace with system76-scheduler?
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
  boot.initrd.kernelModules = [];

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
  hardware.cpu.amd.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;
}
