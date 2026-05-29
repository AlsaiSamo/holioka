{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.hlk.graphical;
in
{
  config = lib.mkIf (cfg.desktopVariant == "wayland") {
    # programs.sway = {
    #   enable = true;
    #   wrapperFeatures.gtk = true;
    # };
    # programs.waybar.enable = true;
    # services.displayManager = {
    #   defaultSession = "none+sway";
    # };
  };
}
