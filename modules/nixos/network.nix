{
  config,
  lib,
  pkgs,
  secrets,
  ...
}: let
  cfg = config.hlk.network;
in {
  options.hlk.network = {
    default.enable = lib.mkEnableOption "default network configuration";
    desktop.enable = lib.mkEnableOption "network tray applet";
    # wireless.enable = lib.mkEnableOption "wireless";
    #TODO: assert that it is not null
    hostName = lib.mkOption {
      #TODO: get host name from the config
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
