{ config, lib, pkgs, ... }:

{
  services.flatpak.enable = true;
  xdg.portal.enable = true;
  xdg.portal.extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
  environment.systemPackages = with pkgs; [
    xdg-desktop-portal
    xdg-desktop-portal-gtk
    libportal
    xorg.xprop
  ];

}
