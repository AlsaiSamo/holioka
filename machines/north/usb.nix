inputs @ {
  lib,
  config,
  pkgs,
  secrets,
  extra,
  modulesPath,
  mobile,
  ...
}: let
  adbdFix = pkgs.callPackage "${mobile}/overlay/adbd" {
    libhybris = pkgs.callPackage "${mobile}/overlay/libhybris" {
      android-headers = pkgs.android-headers;
    };
  };
in
  # Ethernet (RNDIS/NCM) and debugging (ADB) over USB
  #TODO: instead of setting the address through ifconfig, I need to configure a DHCP server
  #or leave it unset so that the phone and the laptop pick an ip from 169.254.0.0/16
  #TODO: make adb work while ncm is enabled
  {
    boot.initrd.kernelModules = ["configfs" "libcomposite" "g_ffs"];
    boot.initrd.availableKernelModules = ["usb_f_rndis" "usb_f_ncm"];

    boot.specialFileSystems = {
      "/sys/kernel/config" = {
        device = "configfs";
        fsType = "configfs";
        options = ["nosuid" "noexec" "nodev"];
      };
    };

    #TODO: insert this into top of the script
    # copy_bin_and_libs ${pkgs.adbdFix}/bin/adbd
    boot.initrd.extraUtilsCommands = ''
      cp -pv ${pkgs.glibc.out}/lib/libnss_files.so.* $out/lib
    '';

    boot.initrd.preLVMCommands = ''
      if ! mountpoint /sys/kernel/config; then
        specialMount configfs /sys/kernel/config nosuid,noexec,nodev configfs
      fi

        mkdir -p /sys/kernel/config/usb_gadget/g1/strings/0x409
        cd /sys/kernel/config/usb_gadget/g1
        echo 0x18D1 > idVendor
        echo 0xD001 > idProduct
        echo oneplus-enchilada > strings/0x409/product
        echo NixOS > strings/0x409/manufacturer
        echo 0123456789 > strings/0x409/serialnumber

        mkdir -p configs/c.1/strings/0x409
        #echo adb > configs/c.1/strings/0x409/configuration
        echo "USB network" > configs/c.1/strings/0x409/configuration

        # mkdir -p functions/ffs.adb
        # ln -s functions/ffs.adb configs/c.1/adb
        mkdir -p functions/ncm.usb0 || mkdir -p functions/rndis.usb0
        ln -s functions/ncm.usb0 configs/c.1/ || ln -s functions/rndis.usb0 configs/c.1/

        # mkdir -p /dev/usb-ffs/adb
        # mount -t functionfs adb /dev/usb-ffs/adb
        # adbd &

        ls /sys/class/udc/ | head -n1 > UDC
        cd /

        ifconfig rndis0 172.16.42.1 || ifconfig usb0 172.16.42.1 || ifconfig eth0 172.16.42.1
    '';

    boot.initrd.postMountCommands = ''
      # pkill -x adbd
    '';

    # systemd.services.adbd = {
    #   description = "adb daemon";
    #   wantedBy = ["multi-user.target"];
    #   serviceConfig = {
    #     ExecStart = "${adbdFix}/bin/adbd";
    #     Restart = "always";
    #   };
    # };

    boot.initrd.network.enable = true;
    boot.initrd.network.udhcpc.enable = false;
  }
