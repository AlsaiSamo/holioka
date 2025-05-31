{
  config,
  lib,
  pkgs,
  modulesPath,
  volatile,
  pkgsARM,
  mobile,
  secrets,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    volatile.north
    #TODO: look into these files and see what they include
    "${mobile}/modules/quirks/qualcomm/sdm845-modem.nix"
    "${mobile}/modules/quirks/audio.nix"
  ];

  nix.settings.cores = 4;

  #makes the screen in tty go black
  services.kmscon.enable = lib.mkForce false;

  systemd.network.links."40-wlan0" = {
    matchConfig.OriginalName = "wlan0";
    linkConfig.MACAddressPolicy = "none";
    #TODO: check that the MAC stays the same
    linkConfig.MACAddress = secrets.north.modemMAC;
  };

  mobile.quirks.audio.alsa-ucm-meld = true;
  environment.systemPackages = [pkgs.alsa-ucm-conf-op];

  services.udev.extraRules = ''
    SUBSYSTEM=="input", KERNEL=="event*", ENV{ID_INPUT}=="1", SUBSYSTEMS=="input", ATTRS{name}=="spmi_haptics", TAG+="uaccess", ENV{FEEDBACKD_TYPE}="vibra"
    SUBSYSTEM=="misc", KERNEL=="fastrpc-*", ENV{ACCEL_MOUNT_MATRIX}+="-1, 0, 0; 0, -1, 0; 0, 0, -1"
  '';

  mobile.quirks.qualcomm.sdm845-modem.enable = true;
  specialisation.nomodem.configuration = {
    mobile.quirks.qualcomm.sdm845-modem.enable = lib.mkForce false;
    systemd.services.q6voiced.enable = false;
  };

  hardware.enableRedistributableFirmware = true;
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "firmware-oneplus-sdm845"
      "firmware-oneplus-sdm845-xz"
    ];
  hardware.firmware = lib.mkAfter [pkgs.enchilada_firmware];

  systemd.services.ModemManager.serviceConfig.ExecStart = ["" "${pkgs.modemmanager}/bin/ModemManager --test-quick-suspend-resume"];

  boot.kernelPackages =
    lib.mkForce (pkgsARM.linuxPackagesFor pkgsARM.linux_enchilada);
  hardware.deviceTree.enable = true;
  hardware.deviceTree.name = "qcom/sdm845-oneplus-enchilada.dtb";
  boot.consoleLogLevel = 7;
  boot.kernelParams = [
    "console=ttyMSM0,115200"
    "console=tty0"
    "dtb=/${config.hardware.deviceTree.name}"
  ];
  system.build.uboot = pkgs.ubootImage;
  boot.loader = {
    grub.enable = false;
    systemd-boot.enable = true;
    systemd-boot.extraFiles.${config.hardware.deviceTree.name} = "${config.hardware.deviceTree.package}/${config.hardware.deviceTree.name}";
    efi.canTouchEfiVariables = false;
  };
  boot.initrd = {
    includeDefaultModules = false;
    kernelModules = [
      "i2c_qcom_geni"
      "rmi_core"
      "rmi_i2c"
      "qcom_spmi_haptics"
      "dm_mod"
      "zfs"
      "spl"
    ];
    availableKernelModules = [
      "configfs"
      "libcomposite"
      "g_ffs"

      "i2c_qcom_geni"
      "rmi_core"
      "rmi_i2c"

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
