{
  config,
  lib,
  pkgs,
  userName,
  secrets,
  ...
}: let
  cfg = config._hlk_auto.graphical;
in {
  #nixos
  config = lib.mkIf (cfg.windowSystem == "xorg") {
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
    services.displayManager.autoLogin.user = cfg.userName;
  };
}
