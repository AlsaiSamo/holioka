{...}: {
  west = {
    #TODO: random encryption
    swapDevices = [
    {
        device = "/dev/disk/by-uuid/553de4ea-dc22-4a77-84f5-a36c6b5dab82";
        priority = 2048;
        }
    ];
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
}
