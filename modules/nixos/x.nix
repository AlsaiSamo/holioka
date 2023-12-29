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
    #TODO: parametrize this?
    #TODO: add alacritty?
    programs.light.enable = true;
    services.xserver = lib.mkIf cfg.default.enable {
      xkbOptions = "grp:caps_toggle";
      autoRepeatDelay = 200;
      autoRepeatInterval = 30;
      enable = true;
      layout = "us,ru";
      displayManager = {
        defaultSession = "none+i3";
      };
      windowManager.i3.enable = true;
    };
    fonts = {fontconfig = {subpixel.rgba = "none";};};
  };
}
