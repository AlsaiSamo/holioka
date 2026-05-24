{
  config,
  lib,
  pkgs,
  ...
}:
#TODO; rethink this (do I really need this? Why does it configure xdg-portal more than flatpak?)
{
  options = {
    hlk.flatpak.default.enable = lib.mkEnableOption "default Flatpak config";
  };
  config = lib.mkIf config.hlk.flatpak.default.enable {
    services.flatpak.enable = true;
    xdg.portal.enable = true;
    xdg.portal.config.common.default = lib.mkDefault [ "gtk" ];
    # xdg.portal.extraPortals = lib.mkDefault (with pkgs; [ xdg-desktop-portal-gtk ]);
    # environment.systemPackages = with pkgs; [
    #   xdg-desktop-portal
    #   xdg-desktop-portal-gtk
    #   libportal
    #   xorg.xprop
    # ];
  };
}
