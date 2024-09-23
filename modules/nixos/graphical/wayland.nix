{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.hlk.system.graphical;
in {
  config = lib.mkIf (cfg.windowSystem == "wayland") {
    #TODO: update i3's config and configure sway
    programs.sway = {
      enable = true;
      wrapperFeatures.gtk = true;
      #TODO: customize or replace
    };
    programs.waybar.enable = true;
    services.displayManager = {
      defaultSession = "none+sway";
    };
  };
}
