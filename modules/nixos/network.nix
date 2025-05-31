{
  config,
  lib,
  pkgs,
  secrets,
  ...
}: let
  cfg = config.hlk.network;
in {
  #TODO: tcpcrypt?
  #TODO: modemmanager
  options.hlk.network = {
    manager = lib.mkOption {
      example = "iwd";
      description = "What should manage networking";
      default = "none";
      type = lib.types.enum ["none" "iwd" "networkmanager"];
    };
    hostName = lib.mkOption {
      description = "Host name";
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
      environment.systemPackages = [pkgs.impala];
      environment.persistence."/state".directories = ["/var/lib/iwd"];
    })
    (lib.mkIf (cfg.manager == "networkmanager") {
      networking = {
        hostName = secrets.${cfg.hostName}.hostName;
        hostId = secrets.${cfg.hostName}.hostId;
        nftables.enable = true;
        networkmanager.enable = true;
        #TODO: persist networkmanager stuff
      };
      environment.persistence."/state".directories = ["/var/lib/NetworkManager"];
    })
  ];
}
