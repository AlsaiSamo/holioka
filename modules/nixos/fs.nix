{ config, lib, ... }@inputs: {
  #TODO: optional state wiping, and since I don't change my layout, it stays the same
  #TODO: make filesystem(s) configurable

  options = {
    stateRemoval.enable = lib.mkOption {
      default = false;
      description =
        "Wipe the state at boot time (requires there to be root@blank, home@blank)";
      type = lib.types.bool;
    };
    defaultFilesystems = lib.mkOption {
      default = false;
      description = "Use the predefined ZFS layout";
      type = lib.types.bool;
    };
  };
  config = {
    fileSystems = lib.mkIf config.defaultFilesystems {
      "/home" = {
        device = "nix_pool/local/home";
        fsType = "zfs";
      };
      "/" = {
        device = "nix_pool/local/root";
        fsType = "zfs";
      };
      "/var/log" = {
        device = "nix_pool/local/log";
        fsType = "zfs";
      };
      "/nix" = {
        device = "nix_pool/local/nix";
        fsType = "zfs";
      };
      "/state" = {
        device = "nix_pool/safe/state";
        fsType = "zfs";
        neededForBoot = true;
      };
      "/state/secrets" = {
        device = "nix_pool/safe/secrets";
        fsType = "zfs";
        neededForBoot = true;
      };
    };
    boot.initrd.postDeviceCommands = lib.mkIf config.stateRemoval.enable
      (lib.mkAfter ''
        zfs rollback -r nix_pool/local/home@blank
        zfs rollback -r nix_pool/local/root@blank
      '');
    environment.persistence."/state" = lib.mkIf config.stateRemoval.enable {
      files = [ "/etc/machine-id" ];
      directories = [ "/etc/NetworkManager/" ];
    };
  };
}
