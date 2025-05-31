{
  config,
  lib,
  pkgs,
  userName,
  secrets,
  ...
}: let
  cfg = config._hlk_auto.graphical;
  modifier = config.wayland.windowManager.sway.config.modifier;
  terminal = config.wayland.windowManager.sway.config.terminal;
  #TODO: persist phosh's files
in {
  #hm
  #TODO: waydroid?
  config = lib.mkIf (cfg.windowSystem == "wayland_mobile") {
    home.packages = with pkgs; [
      squeekboard
    ];
  };
}
