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
  config = lib.mkIf (cfg.desktopVariant == "wayland_mobile") {
    services.displayManager = {
      enable = true;
      #TODO: rewrite to use greetd stuff
      ly.enable = true;
      ly.settings = {
        auth_fails = 65535;
        clear_password = true;
        logout_cmd = "systemctl restart buffyboard";
      };
    };

    xdg.portal.enable = true;
    #TODO: what are the other options?
    xdg.portal.config.common.default = [ "gtk" ];
    xdg.portal.extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];

    #TODO: Should be stopped when wayland compositor boots up
    systemd.services.buffyboard_manual = {
      description = "buffyboard_manual";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.buffyboard}/bin/buffyboard";
        Restart = "on-failure";
        RestartSec = "1";
      };
    };

    # programs.niri = {
    #   enable = true;
    #   package = pkgs.niri-unstable;
    #   #putting my trust in sodiboo
    #   #niri-flake.cache.enable = false;
    # };

    services.xserver.desktopManager.phosh = {
      enable = true;
      group = userName;
      user = userName;
    };

    programs.sway = {
      enable = true;
      package = pkgs.sway_mobile;
    };

    systemd.packages = [
      pkgs.buffyboard
    ];

    environment.systemPackages = with pkgs; [
      buffyboard
      squeekboard
      # wvkbd

      #from plasma mobile
      kdePackages.plasmatube
      kdePackages.alligator
    ];

    environment.persistence."/state".files = [
      "/etc/ly/save.ini"
    ];
  };
}
