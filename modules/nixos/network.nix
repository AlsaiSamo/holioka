{
  config,
  lib,
  pkgs,
  secrets,
  ...
}: let
  cfg = config.hlk.network;
in {
  #TODO: select between different network managing options
  options.hlk.network = {
    default.enable = lib.mkEnableOption "default network configuration";
    desktop.enable = lib.mkEnableOption "network tray applet";
    # wireless.enable = lib.mkEnableOption "wireless";
    hostName = lib.mkOption {
      description = "Host name";
      type = lib.types.str;
    };
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.default.enable {
      #TODO: save iwd state
      # /var/lib/iwd
      networking = {
        hostName = secrets.${cfg.hostName}.hostName;
        hostId = secrets.${cfg.hostName}.hostId;
        nftables.enable = true;
        wireless.iwd.enable = true;
      };
      environment.persistence."/state".directories = ["/var/lib/iwd"];
    })
    (lib.mkIf cfg.desktop.enable {
      environment.systemPackages = with pkgs; [iwgtk];
    })
  ];
}
