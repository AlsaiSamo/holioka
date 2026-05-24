{ ... }:
{
  west = {
    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/D865-B9DC";
      fsType = "vfat";
    };

    boot.initrd.luks.devices = {
      cryptroot = {
        device = "/dev/disk/by-uuid/5639ead7-d91e-4413-9086-2bcf7c1473d3";
        allowDiscards = true;
        bypassWorkqueues = true;
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
        allowDiscards = true;
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
        allowDiscards = true;
      };
    };
  };
}
