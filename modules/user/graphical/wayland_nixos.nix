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
  config = lib.mkIf (cfg.windowSystem == "wayland") {
    services.displayManager = {
      enable = true;
      #NOTE: try lemurs at some point
      ly.enable = true;
      ly.settings = {
        auth_fails = 65535;
        clear_password = true;
      };
    };
    programs.sway = {
      enable = true;
      # wrapperFeatures.gtk = true;
      # #NOTE: hm will enable and configure its own waybar
      # waybar.enable = true;
      # #NOTE: uwsm
    };
    environment.persistence."/state".files = [
      "/etc/ly/save.ini"
    ];
  };
}
