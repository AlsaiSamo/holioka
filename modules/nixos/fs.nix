{
  config,
  lib,
  pkgs,
  ...
}@inputs:
let
  cfg = config.hlk;
in
{
  options.hlk = {
    stateRemoval.enable = lib.mkOption {
      default = false;
      description = "Wipe the state at boot time (requires there to be root@blank, home@blank)";
      type = lib.types.bool;
    };
    datasetPrefix = lib.mkOption {
      default = "";
      description = "Dataset under pool/state where the state datasets reside. Empty = the state datasets reside directly under pool/state.";
      type = lib.types.str;
    };
    defaultFilesystems = lib.mkOption {
      default = false;
      description = "Use the predefined ZFS layout";
      type = lib.types.bool;
    };
    zpool_name = lib.mkOption {
      default = "nix_pool";
      description = "Name of device's zpool";
      type = lib.types.str;
    };
    backup.enable = lib.mkOption {
      default = false;
      description = "Enable automatic snapshots with sanoid";
      type = lib.types.bool;
    };
    projectsDataset.enable = lib.mkOption {
      default = false;
      description = "Enable mounting of safe/projects dataset to home/username/projects";
      type = lib.types.bool;
    };
    musicDataset.enable = lib.mkOption {
      default = false;
      description = "Enable mounting of local/music dataset to local_state/music";
      type = lib.types.bool;
    };
  };
  config =
    let
      #turn the prefix into an actual prefix (or into an empty string)
      prefix = if builtins.stringLength cfg.datasetPrefix > 0 then "${cfg.datasetPrefix}/" else "";
    in
    {
      specialisation."preserve_state" = lib.mkIf cfg.stateRemoval.enable {
        configuration.hlk.stateRemoval.enable = lib.mkForce false;
      };
      fileSystems = lib.mkIf cfg.defaultFilesystems (
        lib.attrsets.mergeAttrsList [
          {
            "/" = {
              device = "${cfg.zpool_name}/local/root";
              fsType = "zfs";
              neededForBoot = true;
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
              device = "${cfg.zpool_name}/local/${prefix}state";
              fsType = "zfs";
              neededForBoot = true;
            };
            #Has home/imikoy
            "/state" = {
              device = "${cfg.zpool_name}/safe/${prefix}state";
              fsType = "zfs";
              neededForBoot = true;
            };
            "/state/secrets" = {
              device = "${cfg.zpool_name}/safe/${prefix}secrets";
              fsType = "zfs";
              neededForBoot = true;
            };
          }
          (
            if cfg.musicDataset.enable then
              {
                "/local_state/music" = {
                  device = "${cfg.zpool_name}/local/music";
                  fsType = "zfs";
                };
              }
            else
              { }
          )
          (
            if cfg.projectsDataset.enable then
              {
                "/state/projects" = {
                  device = "${cfg.zpool_name}/safe/projects";
                  fsType = "zfs";
                };
              }
            else
              { }
          )
        ]
      );
      boot.initrd.postMountCommands =
        lib.mkIf (cfg.stateRemoval.enable && !config.boot.initrd.systemd.enable)
          (
            lib.mkAfter ''
              zfs rollback -r ${cfg.zpool_name}/local/root@blank
            ''
          );
      boot.initrd.systemd.services.zfs-rollback = lib.mkIf cfg.stateRemoval.enable {
        description = "Roll root dataset back to blank snapshot";
        wantedBy = [ "initrd.target" ];
        after = [ "zfs-import-${cfg.zpool_name}.service" ];
        before = [ "sysroot.mount" ];
        path = [ pkgs.zfs ];
        unitConfig.defaultDependencies = "no";
        serviceConfig.Type = "oneshot";
        script = ''
          zfs rollback -r ${cfg.zpool_name}/local/root@blank && echo "ZFS root dataset rollback done"
        '';
      };

      environment.persistence."/state" = {
        files = [
          "/etc/machine-id"
          "/etc/zfs/zpool.cache"
        ];
        directories = [
          #persist uids and gids
          "/var/lib/nixos"
          "/var/lib/systemd"
        ];
      };

      environment.variables = lib.mkIf cfg.stateRemoval.enable {
        PLEASE_PUT_BUILD_ARTIFACTS_IN_TMP = lib.mkDefault "/tmp";
      };

      services.zfs = lib.mkIf cfg.defaultFilesystems {
        trim.enable = true;
        autoScrub = {
          enable = true;
        };
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
