{
  config,
  lib,
  pkgs,
  ...
}: {
  options = {
    hlk.flatpak.default.enable = lib.mkEnableOption "default Flatpak config";
  };
  config = lib.mkIf config.hlk.flatpak.default.enable {
    services.flatpak.enable = true;
    xdg.portal.enable = true;
    xdg.portal.config.common.default = ["gtk"];
    xdg.portal.extraPortals = with pkgs; [xdg-desktop-portal-gtk];
    # environment.systemPackages = with pkgs; [
    #   xdg-desktop-portal
    #   xdg-desktop-portal-gtk
    #   libportal
    #   xorg.xprop
    # ];
  };
}
