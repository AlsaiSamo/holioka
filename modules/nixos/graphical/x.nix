{
  config,
  lib,
  pkgs,
  ...
} @ inputs: let
  cfg = config.hlk.system.graphical;
in {
  config = lib.mkIf (cfg.windowSystem == "xorg") {
    services.xserver = {
      enable = true;
      windowManager.i3.enable = true;
    };
    services.displayManager = {
      defaultSession = "none+i3";
    };
  };
}
