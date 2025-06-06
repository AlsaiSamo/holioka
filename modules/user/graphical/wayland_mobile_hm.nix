{
  config,
  lib,
  pkgs,
  userName,
  secrets,
  ...
}: let
  cfg = config._hlk_auto.graphical;
  modifier = config.wayland.windowManager.sway.config.modifier;
  terminal = config.wayland.windowManager.sway.config.terminal;
  #TODO: persist phosh's files
in {
  #hm
  #TODO: waydroid?
  config = lib.mkIf (cfg.windowSystem == "wayland_mobile") {
    home.packages = with pkgs; [
      squeekboard
    ];

    xdg.autostart = {
      enable = true;
      entries = let
      stop_buffyboard =  
        pkgs.makeDesktopItem {
          name = "stop-buffyboard";
          type = "Application";
          noDisplay = true;
          desktopName = "Stop buffyboard";
          # exec = "systemctl stop buffyboard && pkill buffyboard";
          exec = "${pkgs.writeScript "stop-buffyboard" ''
                systemctl stop buffyboard && pkill buffyboard
          ''}";
        };
      in
      [
      "${stop_buffyboard}/share/applications/stop-buffyboard.desktop"
      ];
    };
  };
}
