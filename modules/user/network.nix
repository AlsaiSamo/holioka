select_user: {
  config,
  lib,
  pkgs,
  userName,
  ...
}:
let
  cfg = config._hlk_auto.network;
  cfgGraphical = config._hlk_auto.graphical.windowSystem;
  options._hlk_auto = {
    manager = lib.mkOption {
      example = "iwd";
      description = "What should manage networking";
      default = "none";
      type = lib.types.enum ["none" "iwd" "networkmanager"];
    };
  };
in {
  inherit options;
  config =
    if select_user
    #hm
    then {
      config = lib.mkMerge [
        (lib.mkIf (cfgGraphical != "none") lib.mkMerge [
          (lib.mkIf (cfg.manager = "iwd") {home.packages = [pkgs.iwgtk];})
        ])
      ]
    }
    #nixos
    else {
      config.hlk.network.manager = cfg.manager;
    };
}
