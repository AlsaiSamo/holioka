{
  config,
  lib,
  ...
} @ inputs: let
  cfg = config.hlk;
in {
  #TODO: make script for generating the pool

  options.hlk = {
    stateRemoval.enable = lib.mkOption {
      default = false;
      description = "Wipe the state at boot time (requires there to be root@blank, home@blank)";
      type = lib.types.bool;
    };
    defaultFilesystems = lib.mkOption {
      default = false;
      description = "Use the predefined ZFS layout";
      type = lib.types.bool;
    };
    zpool_name = lib.mkOption {
      default = "nix_pool";
      description = "Name of device's zpool";
      type = lib.types.string;
    };
    backup.enable = lib.mkOption {
      default = false;
      description = "Enable automatic snapshots with sanoid";
      type = lib.types.bool;
    };
  };
  config = {
    specialisation."preserve_state" = lib.mkIf cfg.stateRemoval.enable {
      configuration.hlk.stateRemoval.enable = lib.mkForce false;
    };
    fileSystems = lib.mkIf cfg.defaultFilesystems {
      #Contains user owned home directory with those dirs that do not need to be persistent.
      "/home" = {
        device = "${cfg.zpool_name}/local/home";
        fsType = "zfs";
      };
      "/" = {
        device = "${cfg.zpool_name}/local/root";
        fsType = "zfs";
      };
      "/var/log" = {
        device = "${cfg.zpool_name}/local/log";
        fsType = "zfs";
      };
      "/nix" = {
        device = "${cfg.zpool_name}/local/nix";
        fsType = "zfs";
      };
      #State that shouldn't be in backups. For example, browser cache.
      #Same layout as /state
      "/local_state" = {
        device = "${cfg.zpool_name}/local/state";
        fsType = "zfs";
        neededForBoot = true;
      };
      #Has home/imikoy
      "/state" = {
        device = "${cfg.zpool_name}/safe/state";
        fsType = "zfs";
        neededForBoot = true;
      };
      "/state/secrets" = {
        device = "${cfg.zpool_name}/safe/secrets";
        fsType = "zfs";
        neededForBoot = true;
      };
    };
    boot.initrd.postMountCommands =
      lib.mkIf cfg.stateRemoval.enable
      (lib.mkAfter ''
        zfs rollback -r ${cfg.zpool_name}/local/home@blank
        zfs rollback -r ${cfg.zpool_name}/local/root@blank
      '');
    environment.persistence."/state" = lib.mkIf cfg.stateRemoval.enable {
      files = ["/etc/machine-id"];
      directories = ["/etc/NetworkManager/"];
    };
    services.sanoid = lib.mkIf cfg.backup.enable {
      enable = true;
      interval = "hourly";
      datasets."${cfg.zpool_name}/safe" = {
        recursive = "zfs";
        yearly = 0;
        monthly = 1;
        daily = 7;
        hourly = 8;
        autosnap = true;
        autoprune = true;
      };
    };
  };
}
