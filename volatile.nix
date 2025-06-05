{...}: {
  west = {
    swapDevices = [
      {
        device = "/dev/disk/by-partuuid/ad50d1df-3db1-49e2-8bfd-ec704e5bbfb0";
        randomEncryption.enable = true;
      }
    ];
    #TODO: test this
    #zramSwap.writebackDevice = "/dev/disk/by-partuuid/ad50d1df-3db1-49e2-8bfd-ec704e5bbfb0";
    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/CEEB-4273";
      fsType = "vfat";
    };

    boot.initrd.luks.devices = {
      cryptroot = {
        device = "/dev/disk/by-uuid/cb49fc83-8af7-47a1-8a59-9946fa36f174";
      };
    };
  };
  east = {
    swapDevices = [
      {
        device = "/dev/disk/by-partuuid/4ef7c7f0-53e6-4051-a37b-8231ecec6207";
        randomEncryption.enable = true;
      }
    ];

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/0784-493A";
      fsType = "vfat";
    };

    boot.initrd.luks.devices = {
      cryptroot = {
        device = "/dev/disk/by-uuid/c0a2fe90-f87e-491d-aaff-ecb28718e396";
      };
    };
  };
  north = {
    hlk.zpool_name = "phone_pool";
    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/DE2B-CC5E";
      fsType = "vfat";
    };
    boot.initrd.luks.devices = {
      cryptroot = {
        device = "/dev/disk/by-uuid/9b292361-00f1-4b03-879b-3dd170c1ff1c";
      };
    };
  };
}
