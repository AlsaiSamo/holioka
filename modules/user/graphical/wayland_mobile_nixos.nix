{
  config,
  lib,
  pkgs,
  userName,
  secrets,
  ...
}: let
  cfg = config._hlk_auto.graphical;
in {
  #nixos
  config = lib.mkIf (cfg.windowSystem == "wayland_mobile") {
    services.displayManager = {
      enable = true;
      #NOTE: try lemurs at some point
      ly.enable = true;
      ly.settings = {
        auth_fails = 65535;
        clear_password = true;
        #TODO: disable phosh's autologin or put a .desktop file to ~/.config/autostart that disables buffyboard
        #or leave phosh autologin and disable buffyboard
        #login_cmd = "systemctl stop buffyboard; pkill buffyboard; exec \"$@\"";
      };
    };

    xdg.portal.enable = true;
    xdg.portal.config.common.default = ["gtk"];
    xdg.portal.extraPortals = with pkgs; [xdg-desktop-portal-gtk];

    #NOTE: includes a systemd unit that starts phosh, bypassing display manager.
    #NOTE: also will launch .desktop files in ~/.config/autostart/
    # services.xserver.desktopManager.phosh = {
    #   enable = true;
    #   group = "${userName}";
    #   user = "${userName}";
    # };

    #TODO: look at sodiboo/niri-flake, sodiboo's config, and configure niri here and/or in hm config
    environment.variables.NIXOS_OZONE_WL = "1";
    # putting my trust in sodiboo on this one
    # niri-flake.cache.enable = false;
    programs.niri = {
      enable = true;
      # settings = {};
    };

    environment.systemPackages = with pkgs; [
      squeekboard
    ];

    environment.persistence."/state".files = [
      "/etc/ly/save.ini"
    ];
  };
}
