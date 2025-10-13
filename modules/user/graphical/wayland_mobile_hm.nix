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
  modifier = config.wayland.windowManager.sway.config.modifier;
  terminal = config.wayland.windowManager.sway.config.terminal;
in
{
  #hm
  #TODO: waydroid?
  config = lib.mkIf (cfg.windowSystem == "wayland_mobile") {
    home.packages = with pkgs; [
      chatty
      cliphist
    ];

    #TODO: what to configure:
    # 1. Sway (configure key presses, touch config)
    # 2. Squeekboard (should have a layout that provides modifier keys, currently the Terminal one is greyed out)
    # 3. Lockscreen

    #XXX: cannot make a group drop down?
    programs.waybar = {
      enable = true;
      systemd.enable = true;
      style = builtins.readFile ../../../dotfiles/waybar_mobile/style.css;
      settings.main = {
        position = "top";
        reload_style_on_change = true;
        exclusive = true;
        fixed-center = true;
        layer = "top";
        margin = "0";
        spacing = "6";
        height = 30;
        ipc = true;
        id = "bar-0";
        modules-left = [
          "idle_inhibitor"
          "clock#time"
          "pulseaudio"
          "group/bat"
          "group/load"
        ];
        modules-right = [
          "tray"
          "custom/keeb"
        ];
        include = [
          ../../../dotfiles/waybar_mobile/modules.jsonc
          # ../../../dotfiles/waybar_mobile/config
        ];
      };
    };

    #TODO: add meta key
    xdg.dataFile."squeekboard" = {
      source = ../../../dotfiles/squeekboard;
      recursive = true;
    };

    # programs.niri = {
    #   enable = true;
    #   package = pkgs.niri-unstable;
    #   settings = {
    #     #TODO:
    #     # binds = {};
    #     # the default is ok
    #     # screenshot-path = "~";
    #     hotkey-overlay.skip-at-startup = true;
    #     prefer-no-csd = true;
    #     spawn-at-startup = [
    #       {command = ["waybar"];}
    #     ];
    #     #won't use this on the phone?
    #     # overview = {};
    #     input = {
    #       focus-follows-mouse = {
    #         #TODO: test this
    #         # enable = true;
    #         # max-scroll-amount = 0;
    #       };
    #       keyboard = {
    #         repeat-delay = 200;
    #         repeat-rate = 30;
    #         track-layout = "global";
    #         xkb = {
    #           layout = "us,ru";
    #           options = "grp:caps_toggle";
    #         };
    #       };
    #       #TODO: add this to squeekboard first. For now, it'll be Alt.
    #       # mod-key = "Super";
    #       mod-key = "Alt";
    #       mouse = {
    #         accel-profile = "flat";
    #         scroll-method = "two-finger";
    #       };
    #       power-key-handling.enable = false;
    #       touchpad = {
    #         accel-profile = "flat";
    #         click-method = "clickfinger";
    #         drag = true;
    #         dwt = true;
    #         scroll-method = "two-finger";
    #         tap = true;
    #         tap-button-map = "left-right-middle";
    #       };
    #       warp-mouse-to-focus.enable = false;
    #     };
    #         #TODO: outputs should be configured in North's config
    #         #outputs = {};
    #         cursor = {
    #           hide-when-typing = true;
    #           #TODO: theme = "";
    #         };
    #         layout = {
    #           #TODO: try this
    #           border = {
    #             # enable = true;
    #             # width = 2;
    #             #active =
    #             #inactive =
    #             #urgent =
    #           };
    #           focus-ring = {
    #             width = 2;
    #             #TODO:
    #             #active =
    #             #inactive =
    #             #urgent =
    #           };
    #           #TODO:
    #           # insert-hint = {
    #           # };
    #         };
    #         #TODO:
    #         #animations = {};
    #         gestures = {
    #           dnd-edge-view-scroll = {
    #             delay-ms = 500;
    #             #TODO: there's more config options here
    #           };
    #           hot-corners.enable = false;
    #         };
    #         #environment = {};
    #         #window-rules = {};
    #         #layer-rules = {};
    #         # xwayland-satellite = {
    #         #   enable = true;
    #         #   path = lib.getExe pkgs.xwayland-satellite-unstable;
    #         # };
    #       # };
    #     # };
    #   };
    # };

    #TODO: configure this now
    #1. Power button should turn the screen on and off, later it should also lock the session
    #2. The volume buttons should control the volume.
    #3. Look at other sway configuration options
    #4. (maybe) light up the LED a little bit? to indicate when the phone is suspended (if the LED turns off in that case)
    wayland.windowManager.sway = {
      enable = true;
      package = pkgs.sway_mobile;
      systemd.enable = true;
      config = {
        terminal = "alacritty msg create-window $HOME || alacritty";
        menu = "fuzzel";
        modifier = "Mod1";
        defaultWorkspace = "workspace \"1\"";
        fonts = {
          names = [ "Hack Nerd Font" ];
          style = "Regular";
          size = 8.0;
        };
        #NOTE: output config should be done per machine or per hardware
        focus = {
          mouseWarping = false;
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
          border = 4;
          titlebar = false;
          commands = [ ];
        };
        bars = [
          {
            id = "bar-0";
            command = "${pkgs.waybar}/bin/waybar";
          }
        ];
        startup = [
          {
            command = "wl-paste --watch cliphist store";
          }
          {
            command = "systemctl stop buffyboard_manual";
          }
          {
            command = "squeekboard &";
          }
          #TODO: isn't touchable? But if I run exec waybar or start it manually it works ok?
          #Or is the issue that the affected modules launch commands to do things?
          # {
          #   command = "waybar";
          # }
        ];
        # keybindings = {
        #   # "XF86PowerOff"
        # };
        floating.criteria = [
          { window_role = "pop-up"; }
          { window_role = "task_dialog"; }
          { instance = "Steam"; }
          { title = "Origin"; }
          { title = "Zoom Meeting"; }
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
        #TODO: output configuration in North's config
        #TODO: keybinds
        #TODO: bind volume buttons
        #TODO: bind launcher opening
        #TODO: bind for suspend
        #TODO: bind for cliphist (and also cliphist)
        #TODO: binds for switching workspaces? Or does this go into waybar?
        #TODO: terminal
        #TODO: launch waybar
        #TODO: touch config
        #TODO: toggle the screen on power button (should also lock the phone, but is there a lockscreen that does that?)
      };
    };

    services.cliphist = {
      enable = true;
      extraOptions = [
        "-max-items"
        "30"
      ];
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

    services.swayidle = {
      enable = true;
      events = [
        # {
        #   event = "before-sleep";
        #   command = "${pkgs.swaylock-effects}/bin/swaylock -f -C $HOME/.config/swaylock/config";
        # }
        # {
        #   event = "lock";
        #   command = "${pkgs.swaylock-effects}/bin/swaylock -f -C $HOME/.config/swaylock/config";
        # }
      ];
      timeouts = [
        {
          timeout = 1800;
          command = "${pkgs.systemd}/bin/systemctl suspend";
        }
        # {
        #   timeout = 300;
        #   command = "${pkgs.swaylock-effects}/bin/swaylock -f -C $HOME/.config/swaylock/config";
        # }
      ];
    };

    #TODO: use this in Sway to kill buffyboard.
    xdg.autostart = {
      enable = true;
      entries =
        let
          stop_buffyboard = pkgs.makeDesktopItem {
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
