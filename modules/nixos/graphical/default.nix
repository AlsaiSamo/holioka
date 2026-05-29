{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.hlk.graphical;
in
#WARN: configuration of GUI as nixos module isn't maintained.
{
  imports = [
    ./x.nix
    ./wayland.nix
  ];
  options.hlk.graphical = {
    desktopVariant = lib.mkOption {
      example = "xorg";
      description = "What windowing system and the respective environment to enable in the system";
      default = "none";
      type = lib.types.enum [
        "none"
        "xorg"
        "wayland"
      ];
    };
  };
  config = lib.mkIf (cfg.desktopVariant != "none") {
    environment.systemPackages = with pkgs; [
      alacritty
      brightnessctl
    ];
    fonts = {
      fontconfig = {
        subpixel.rgba = "none";
      };
    };
    xdg.portal.enable = lib.mkDefault true;
    # xdg.portal.xdgOpenUsePortal = true;
  };
}
