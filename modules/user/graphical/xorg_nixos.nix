{
  config,
  lib,
  pkgs,
  userName,
  secrets,
  ...
}:
let
  cfg = config._hlk_auto.graphical;
in
{
  #nixos
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
    services.displayManager.autoLogin.user = userName;
    environment.persistence."/state".users.${userName} = {
      directories = [
        ".cache/betterlockscreen"
      ];
      files = [
        ".cache/rofi3.druncache"
      ];
    };
  };
}
