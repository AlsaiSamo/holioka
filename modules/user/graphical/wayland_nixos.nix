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
  config = lib.mkIf (cfg.desktopVariant == "wayland") {
    services.greetd = {
      enable = true;
      restart = true;
      useTextGreeter = true;
      settings = {
        terminal.vt = 1;
        default_session.command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-user-session --cmd sway";
      };
    };

    programs.sway = {
      enable = true;
      # wrapperFeatures.gtk = true;
      # #NOTE: hm will enable and configure its own waybar
    };
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal
        #file picker, app chooser, etc.
        xdg-desktop-portal-gtk
        #screencasting
        xdg-desktop-portal-wlr
      ];
      config.common.default = "gtk";
    };
    environment.persistence."/state".files = [
      "/var/cache/tuigreet"
    ];
    systemd.user.extraConfig = ''
      DefaultEnvironment="PATH=/run/wrappers/bin:/etc/profiles/per-user/%u/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin"
    '';
  };
}
