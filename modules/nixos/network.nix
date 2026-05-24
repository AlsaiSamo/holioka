{
  config,
  lib,
  pkgs,
  secrets,
  ...
}:
let
  cfg = config.hlk.network;
in
{
  #TODO: modemmanager config for oneplus
  options.hlk.network = {
    manager = lib.mkOption {
      example = "iwd";
      description = "What should manage networking";
      default = "none";
      type = lib.types.enum [
        "none"
        "iwd"
        "networkmanager"
      ];
    };
    hostName = lib.mkOption {
      description = "What host this is (e.q. West, East; actual hostname is taken from secrets.nix)";
      type = lib.types.str;
    };
  };
  config = lib.mkMerge [
    (lib.mkIf (cfg.manager == "iwd") {
      networking = {
        hostName = secrets.${cfg.hostName}.hostName;
        hostId = secrets.${cfg.hostName}.hostId;
        nftables.enable = true;
        wireless.iwd.enable = true;
      };
      environment.systemPackages = [ pkgs.impala ];
      environment.persistence."/state".directories = [ "/var/lib/iwd" ];
    })
    (lib.mkIf (cfg.manager == "networkmanager") {
      networking = {
        hostName = secrets.${cfg.hostName}.hostName;
        hostId = secrets.${cfg.hostName}.hostId;
        nftables.enable = true;
        networkmanager.enable = true;
      };
      environment.persistence."/state".directories = [ "/var/lib/NetworkManager" ];
    })
  ];
}
