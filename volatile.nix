{...}: {
  west = {
    swapDevices = [{device = "/dev/disk/by-uuid/553de4ea-dc22-4a77-84f5-a36c6b5dab82";}];
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
}
