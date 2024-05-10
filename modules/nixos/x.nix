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
      xkb.options = "grp:caps_toggle";
      autoRepeatDelay = 200;
      autoRepeatInterval = 30;
      enable = true;
      xkb.layout = "us,ru";
      windowManager.i3.enable = true;
    };
    services.displayManager = {
      defaultSession = "none+i3";
    };
    fonts = {fontconfig = {subpixel.rgba = "none";};};
    xdg.portal.enable = true;
    xdg.portal.xdgOpenUsePortal = true;
  };
}
