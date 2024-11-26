{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.hlk.graphical;
in {
  imports = [./x.nix ./wayland.nix];
  options.hlk.graphical = {
    windowSystem = lib.mkOption {
      example = "xorg";
      description = "What windowing system and the respective environment to enable in the system";
      default = "none";
      type = lib.types.enum ["none" "xorg" "wayland"];
    };
  };
  config = lib.mkIf (cfg.windowSystem != "none") {
    services.xserver = {
      #TODO: doesn't apply to wayland
      xkb.options = "grp:caps_toggle";
      autoRepeatDelay = 200;
      autoRepeatInterval = 30;
      xkb.layout = "us,ru";
    };
    environment.systemPackages = with pkgs; [
      alacritty
      brightnessctl
    ];
    fonts = {fontconfig = {subpixel.rgba = "none";};};
    xdg.portal.enable = true;
    xdg.portal.xdgOpenUsePortal = true;
  };
}
