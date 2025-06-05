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
  #hm
  config = lib.mkIf (cfg.windowSystem == "xorg") {
    home.packages = with pkgs; [
      i3
      rofi-power-menu
      warpd

      xclip
      xdotool
      shotgun
      slop
    ];

    #TODO: configure correctly, it is now using j for scrolling down
    xdg.configFile."warpd/config".source = ../../../dotfiles/warpd/config;

    services.betterlockscreen = {
      enable = true;
      inactiveInterval = 5;
      arguments = ["blur" "0.5"];
    };

    xdg.configFile."i3/config".source = ../../../dotfiles/i3/config;
    services.polybar = {
      enable = true;
      package = pkgs.polybarFull;
      config = ../../../dotfiles/polybar/config.ini;
      script = ''
        pkill polybar
        #All monitor names, the ones that don't exist will simply not launch
        for m in HDMI-0 eDP-1 eDP eDP-1-0 DP-1; do
          MONITOR=$m polybar default 2>/tmp/polybar.$m &
        done
        exit 0
      '';
    };

    programs.rofi = {
      enable = true;
      cycle = true;
      location = "center";
      theme = "gruvbox-dark-soft";
      plugins = with pkgs; [rofi-power-menu];
      extraConfig = {
        width = 50;
        lines = 20;
        columns = 1;
        show-icons = true;
      };
    };

    services.picom = {
      enable = true;
      shadow = false;
      fade = true;
      fadeDelta = 2;
      fadeExclude = ["x = 0 && y = 0 && override_redirect = true"];

      inactiveOpacity = 1.0;
      menuOpacity = 1.0;
      activeOpacity = 1.0;
      opacityRules = ["95:class_g = 'Alacritty' && !focused"];
      vSync = true;
    };

    home.persistence."/state/home/${userName}" = {
      directories = [
        ".cache/betterlockscreen"
      ];
      files = [
        ".cache/rofi3.druncache"
      ];
    };
  };
}
