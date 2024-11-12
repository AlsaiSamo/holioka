{
  config,
  lib,
  pkgs,
  modulesPath,
  volatile,
  pkgsARM,
  mobile,
  ...
}: {
  #TODO: bringup here
  #TODO: use mobile-nixos
  imports = [(modulesPath + "/installer/scan/not-detected.nix") volatile.north];

  nix.settings.cores = 4;

  boot.kernelPackages =
    lib.mkForce (pkgsARM.linuxPackagesFor
      (pkgsARM.ccachePkgs.buildLinuxWithCcache pkgsARM.linux_enchilada));
  boot.loader = {
    grub.enable = false;
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = false;
  };
  boot.initrd = {
    #TODO: what if some modules are needed but don't exist?
    includeDefaultModules = false;
    #NOTE: taken from Chayleaf
    kernelModules = [
      # for adb
      "configfs"
      "libcomposite"
      "g_ffs"
      # idk what this is for, but postmarketos adds these
      "i2c_qcom_geni"

      "i2c_qcom_geni"
      "rmi_core"
      "rmi_i2c"
      "qcom_spmi_haptics"

      "ext2"
      "ext4"
      "mmc_block"
      "sd_mod"
      "uhci_hcd"
      "ehci_hcd"
      "ehci_pci"
      "ohci_hcd"
      "ohci_pci"
      "xhci_hcd"
      "xhci_pci"
      "usbhid"
      "hid_generic"
      "hid_lenovo"
      "hid_apple"
      "hid_roccat"
      "hid_logitech_hidpp"
      "hid_logitech_dj"
      "hid_microsoft"
      "hid_cherry"
      "hid_corsair"
      "zfs"
      "spl"
      "dm_mod"
    ];
  };
}
