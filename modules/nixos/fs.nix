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
      #State that shouldn't be in backups. For example, browser cache.
      #Same layout as /state
      "/local_state" = {
        device = "nix_pool/local/state";
        fsType = "zfs";
        neededForBoot = true;
      };
      #Has home/imikoy
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
    boot.initrd.postMountCommands =
      lib.mkIf cfg.stateRemoval.enable
      (lib.mkAfter ''
        zfs rollback -r nix_pool/local/home@blank
        zfs rollback -r nix_pool/local/root@blank
      '');
    environment.persistence."/state" = lib.mkIf cfg.stateRemoval.enable {
      files = ["/etc/machine-id"];
      directories = ["/etc/NetworkManager/"];
    };
    services.sanoid = lib.mkIf cfg.backup.enable {
      enable = true;
      interval = "hourly";
      datasets."nix_pool/safe" = {
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
