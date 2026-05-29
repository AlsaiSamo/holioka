{
  config,
  lib,
  pkgs,
  ...
}@inputs:
let
  cfg = config.hlk.graphical;
in
{
  config = lib.mkIf (cfg.desktopVariant == "xorg") {
    services.xserver = {
      enable = true;
      windowManager.i3.enable = true;
      xkb.options = "grp:caps_toggle";
      autoRepeatDelay = 200;
      autoRepeatInterval = 30;
      xkb.layout = "us,ru";
    };
    services.displayManager = {
      defaultSession = "none+i3";
    };
  };
}
