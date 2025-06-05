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
in {
  #TODO: try niri in the future
  #hm
  #TODO: waydroid?
  config = lib.mkIf (cfg.windowSystem == "wayland") {
    home.packages = with pkgs; [
      swaybg
      wayshot
      slurp
      wl-clipboard
      wl-kbptr
      wlrctl
      #for ifne
      moreutils
    ];

    xdg.configFile."wl-kbptr/config".source = ../../../dotfiles/wl-kbptr.conf;

    wayland.windowManager.sway = {
      checkConfig = false;
      enable = true;
      extraConfig = lib.concatStringsSep "\n" [
        "mouse_warping none"
        "output * bg ${config.xdg.userDirs.pictures}/wallpaper.png fit"

        "bindsym ${modifier}+Ctrl+l exec"
        "bindsym --release ${modifier}+Ctrl+l exec swaylock -f"

        "unbindsym ${modifier}+Shift+q"
        #NOTE: workaround for https://github.com/swaywm/sway/issues/6456
        "bindsym ${modifier}+Shift+q exec"
        "bindsym --release ${modifier}+Shift+q kill"

        #Taken from wl-kbptr's readme
        #TODO: want to have warpd's smoothness...
        #TODO: make the mouse look different? how can this be done?
        "mode Mouse {"
        "# Mouse move"
        "bindsym Left exec wlrctl pointer move -5 0"
        "bindsym Down exec wlrctl pointer move 0 5"
        "bindsym Up exec wlrctl pointer move 0 -5"
        "bindsym Right exec wlrctl pointer move 5 0"

        "# Left button"
        "bindsym m exec wlrctl pointer click left"

        "# Middle button"
        "bindcode 59 exec wlrctl pointer click middle"

        "# Right button"
        "bindcode 60 exec wlrctl pointer click right"
        "bindsym Escape mode default"
        "}"
        #End of wl-kbptr's readme segment

        #TODO: would be cool to have $mod+m switch from floating to tile if pressed after launch
        "unbindsym ${modifier}+j"
        "bindsym ${modifier}+j exec pgrep wl-kbptr || wl-kbptr -c $HOME/${config.xdg.configFile."wl-kbptr/config".target} -o modes=floating',' -o mode_floating.source=detect && swaymsg mode Mouse"
        "bindsym ${modifier}+m exec pgrep wl-kbptr || wl-kbptr -c $HOME/${config.xdg.configFile."wl-kbptr/config".target} -o modes=tile',' && swaymsg mode Mouse"
        "bindsym ${modifier}+n mode Mouse"

        "bindsym ${modifier}+Ctrl+p exec pgrep wleave || wleave -b4 -c10 -p layer-shell"

        #FIX: doen't work on East due to Shift-Print not being registered
        "bindsym Print+Shift exec wayshot -s \"$(slurp)\" --stdout | ifne tee ${config.xdg.userDirs.pictures}/screenshot_$(date +'%y-%m-%d_%T').png | wl-copy"
        "bindsym --release Print exec wayshot --stdout | ifne tee ${config.xdg.userDirs.pictures}/screenshot_$(date +'%y-%m-%d_%T').png | wl-copy"

        "bindcode Ctrl+47 exec cliphist list | fuzzel -d -w80 | cliphist decode | wl-copy"
        "bindcode Ctrl+Shift+47 exec cliphist wipe"

        "bindsym --locked XF86MonBrightnessUp    exec --no-startup-id brightnessctl s +2%"
        "bindsym --locked XF86MonBrightnessDown  exec --no-startup-id brightnessctl s 2%-"
        "bindsym --locked XF86AudioRaiseVolume   exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ +5%"
        "bindsym --locked XF86AudioLowerVolume   exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ -5%"
        "bindsym --locked XF86AudioMute          exec --no-startup-id pactl set-sink-mute @DEFAULT_SINK@ toggle"
        "bindsym --locked XF86AudioMicMute       exec --no-startup-id pactl set-source-mute @DEFAULT_SOURCE@ toggle"

        "bindsym ${modifier}+shift+f move workspace to output next"
      ];
      config = {
        terminal = "alacritty msg create-window $HOME || alacritty";
        menu = "fuzzel";
        modifier = "Mod4";
        defaultWorkspace = "workspace \"1\"";
        fonts = ["Hack Nerd Font 8"];
        #NOTE: output config should be done per machine or per hardware
        focus = {
          newWindow = "urgent";
          wrapping = "workspace";
        };
        input = {
          "type:keyboard" = {
            repeat_delay = "200";
            repeat_rate = "30";
            xkb_layout = "us,ru";
            xkb_options = "grp:caps_toggle";
          };
          "type:touchpad" = {
            natural_scroll = "enabled";
          };
        };
        window = {
          border = 1;
          titlebar = false;
          commands = [];
        };
        startup = [
          {
            command = "wl-paste --watch cliphist store";
          }
        ];
        floating.criteria = [
          {window_role = "pop-up";}
          {window_role = "task_dialog";}
          {instance = "Steam";}
          {title = "Origin";}
          {title = "Zoom Meeting";}
          {
            instance = "qemu";
            class = "Qemu-system-x86_64";
          }
        ];
        colors = {
          background = "#282828";
          focused = {
            background = "#1d2021";
            border = "#bdae93";
            childBorder = "#bdae93";
            text = "#ebdbb2";
            indicator = "#b16286";
          };
          focusedInactive = {
            background = "#1d2021";
            border = "#7c6f64";
            childBorder = "#7c6f64";
            text = "#928374";
            indicator = "#8f3f71";
          };
          unfocused = {
            background = "#32302f";
            border = "#504945";
            childBorder = "#504945";
            text = "#7c6f64";
            indicator = "#652c4f";
          };
          urgent = {
            background = "#1d2021";
            border = "#fb4934";
            childBorder = "#fb4934";
            text = "#ebdbb2";
            indicator = "#d3869b";
          };
        };
      };
    };

    programs.waybar = {
      enable = true;
      systemd.enable = true;
      style = builtins.readFile ../../../dotfiles/waybar/waybar.css;
      settings.main = {
        include = [
          # Modules are configured here
          ../../../dotfiles/waybar/waybar.jsonc
        ];
        layer = "top";
        position = "left";
        width = 40;
        ipc = true;
        id = "bar-0";
        modules-left = ["clock#time" "clock#date" "pulseaudio" "battery" "memory" "cpu" "network" "sway/language" "keyboard-state" "sway/mode"];
        modules-center = ["sway/workspaces"];
        modules-right = ["idle_inhibitor" "tray"];
        margin = "0";
        spacing = "6";
        exclusive = true;
        fixed-center = true;
        reload_style_on_change = true;
      };
    };

    programs.fuzzel = {
      enable = true;
      settings = {
        main = {
          font = "Hack Nerd Font:size=8";
          use-bold = "yes";
          prompt = "\"\"";
          fields = "filename,name,generic,categories,keywords,exec";
          show-actions = "yes";
          tabs = "4";
          horizontal-pad = "2";
          vertical-pad = "2";
          image-size-ratio = "0";
        };
        colors = {
          background = "1d2021ff";
          text = "ebdbb2ff";
          prompt = "ebdbb2ff";
          placeholder = "a89984ff";
          input = "d79921ff";
          match = "b16286ff";
          selection = "3c3836ff";
          selection-text = "fbf1c7ff";
          selection-match = "d3869bff";
          border = "83a598ff";
        };
        border.radius = 0;
        border.width = 2;
      };
    };
    programs.wlogout = {
      enable = true;
      package = pkgs.wleave;
      layout = [
        # {
        #   label = "lock";
        #   action = "loginctl lock-session";
        #   text = "Lock";
        # }
        {
          label = "logout";
          action = "loginctl terminate-user $USER";
          text = "Log out";
        }
        {
          label = "suspend";
          action = "systemctl suspend";
          text = "Suspend";
        }
        {
          label = "shutdown";
          action = "loginctl lock-session";
          text = "Power off";
        }
        {
          label = "reboot";
          action = "systemctl reboot";
          text = "Reboot";
        }
      ];
      #TODO: fix style
      style = ''
        window {
        	background-color: rgba(20, 14, 28, 0.85);
        	background-image: none;
        }

        button {
            font: 1em "Fira Code";
            border-radius: 4px;
            border-color: #8F3F71;
            color: #FFFFFF;
        	background-color: rgba(30, 30, 30, 0.5);
        	border-style: solid;
        	border-width: 2px;
            text-decoration-color: #FFFFFF;
            background-repeat: no-repeat;
            background-position: center;
            background-size: 25%;
        }

        button:active, button:focus, button:hover {
        	background-color: #3700B3;
        	outline-style: none;
        }

        #reboot {
            background-image: image(url("${pkgs.wlogout}/share/wlogout/icons/reboot.png"), url("/usr/local/share/wlogout/icons/reboot.png"));
        }

        #shutdown {
            background-image: image(url("${pkgs.wlogout}/share/wlogout/icons/shutdown.png"), url("/usr/local/share/wlogout/icons/shutdown.png"));
        }

        #suspend {
            background-image: image(url("${pkgs.wlogout}/share/wlogout/icons/suspend.png"), url("/usr/local/share/wlogout/icons/suspend.png"));
        }

        #logout {
            background-image: image(url("${pkgs.wlogout}/share/wlogout/icons/logout.png"), url("/usr/local/share/wlogout/icons/logout.png"));
        }

        #lock {
            background-image: image(url("${pkgs.wlogout}/share/wlogout/icons/lock.png"), url("/usr/local/share/wlogout/icons/lock.png"));
        }
      '';
    };

    services.cliphist = {
      enable = true;
      extraOptions = ["-max-items" "30"];
    };

    programs.swaylock = {
      enable = true;
      package = pkgs.swaylock-effects;
      settings = {
        image = "${config.xdg.userDirs.pictures}/wallpaper.png";
        show-keyboard-layout = true;
        indicator-caps-lock = true;
        font = "Hack Nerd Font";
        font-size = 14;
        indicator-idle-visible = true;
        indicator-radius = 50;
        indicator-thickness = 6;
        indicator-x-position = 150;
        indicator-y-position = 150;
        inside-color = "8f3f7140";
        inside-clear-color = "af3a03d8";
        inside-caps-lock-color = "cc241dd8";
        inside-wrong-color = "9d0006e0";
        inside-ver-color = "45858880";
        bs-hl-color = "d65d0e";
        key-hl-color = "b16286";
        caps-lock-bs-hl-color = "fe8019";
        caps-lock-key-hl-color = "fe8019";
        layout-bg-color = "000000";
        layout-border-color = "000000";
        layout-text-color = "fbf1c7";
        ring-color = "d79921";
        ring-clear-color = "b57614";
        ring-caps-lock-color = "fb4934";
        ring-ver-color = "076678";
        ring-wrong-color = "cc241d";
        separator-color = "8ec07c";
        text-color = "fbf1c7";
        clock = true;
        effect-blur = "2x4";
        line-color = "1d2021";
        line-clear-color = "1d2021";
        line-ver-color = "1d2021";
        line-caps-lock-color = "1d2021";
        line-wrong-color = "1d2021";
      };
    };

    services.swayidle = {
      enable = true;
      events = [
        {
          event = "before-sleep";
          command = "${pkgs.swaylock-effects}/bin/swaylock -f -C $HOME/.config/swaylock/config";
        }
        {
          event = "lock";
          command = "${pkgs.swaylock-effects}/bin/swaylock -f -C $HOME/.config/swaylock/config";
        }
      ];
      timeouts = [
        {
          timeout = 1800;
          command = "${pkgs.systemd}/bin/systemctl suspend";
        }
        {
          timeout = 300;
          command = "${pkgs.swaylock-effects}/bin/swaylock -f -C $HOME/.config/swaylock/config";
        }
      ];
    };
  };
}
