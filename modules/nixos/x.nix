{
  config,
  lib,
  pkgs,
  ...
} @ inputs: let
  cfg = config.hlk.xserver;
in {
  options = {
    hlk.xserver.default.enable = lib.mkEnableOption "default X configuration";
  };
  config = {
    programs.light.enable = true;
    services.xserver = lib.mkIf cfg.default.enable {
      xkbOptions = "grp:caps_toggle";
      autoRepeatDelay = 200;
      autoRepeatInterval = 30;
      enable = true;
      layout = "us,ru";
      displayManager = {
        defaultSession = "none+i3";
        #TODO: should be username-agnostic and probably moved out
        # autoLogin.user = "imikoy";
      };
      windowManager.i3.enable = true;
    };
    fonts = {fontconfig = {subpixel.rgba = "none";};};
  };
}
