select_user: {
  config,
  lib,
  pkgs,
  userName,
  ...
}: let
  cfg = config._hlk_auto.network;
  cfgGraphical = config._hlk_auto.graphical.windowSystem;
  options._hlk_auto.network = {
    manager = lib.mkOption {
      example = "iwd";
      description = "What should manage networking";
      default = "none";
      type = lib.types.enum ["none" "iwd" "networkmanager" "nm+mm"];
    };
    hostName = lib.mkOption {
      default = "";
      description = "Host name";
      type = lib.types.str;
    };
  };
in {
  inherit options;
  config =
    if select_user
    #hm
    then
      lib.mkMerge [
        (lib.mkIf (cfgGraphical != "none") (lib.mkMerge [
          (lib.mkIf (cfg.manager == "iwd") {home.packages = [pkgs.iwgtk];})
          # (lib.mkIf (cfg.manager == "networkmanager") {})
          # (lib.mkIf (cfg.manager == "nm+mm") {})
          #TODO: networkmanager and modemmanager
        ]))
      ]
    #nixos
    else
      (lib.mkMerge [
        (lib.mkIf (cfg.manager != "none") {
          hlk.network.manager = cfg.manager;
        })
        (lib.mkIf (cfg.hostName != "") {
          hlk.network.hostName = cfg.hostName;
        })
        #TODO: networkmanager and modemmanager config and state persisting
        # (lib.mkIf (cfg.manager == "iwd") {home.packages = [pkgs.iwgtk];})
        # (lib.mkIf (cfg.manager == "networkmanager") {})
        # (lib.mkIf (cfg.manager == "nm+mm") {})
      ]);
}
