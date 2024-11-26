{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.hlk.graphical;
in {
  #TODO: figure out if this config does shadow the user's config if enabled
  #as the wiki says
  config = lib.mkIf (cfg.windowSystem == "wayland") {
    #TODO: update i3's config and configure sway
    # programs.sway = {
    #   enable = true;
    #   wrapperFeatures.gtk = true;
    #   #TODO: customize or replace
    # };
    # programs.waybar.enable = true;
    # services.displayManager = {
    #   defaultSession = "none+sway";
    # };
  };
}
