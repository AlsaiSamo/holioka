select_user: {
  config,
  lib,
  pkgs,
  userName,
  secrets,
  ...
}: let
  cfg = config._hlk_auto.graphical;
  options._hlk_auto.graphical = {
    windowSystem = lib.mkOption {
      example = "xorg";
      description = "What windowing system and the respective environment to enable for the user";
      default = "none";
      type = lib.types.enum ["none" "xorg" "wayland"];
    };
  };
in {
  inherit options;
  #Both files do their own checks
  imports =
    if select_user
    #hm
    then [./wayland_hm.nix ./xorg_hm.nix]
    #nixos
    else [./wayland_nixos.nix ./xorg_nixos.nix];
  #Handling of selecting either option
  config =
    if select_user
    #hm
    then
      (lib.mkIf (cfg.windowSystem != "none") {
        home.packages = with pkgs; [
          dconf

          sarasa-gothic
          noto-fonts-color-emoji
          font-awesome
          (nerdfonts.override {fonts = ["FiraCode" "Iosevka" "Hack"];})

          alacritty
          warpd
          mpv
          #TODO: find a better image viewer
          feh

          kdePackages.dolphin
          kdePackages.qtwayland
          kdePackages.qtsvg
          #pcmanfm

          #thumbnail stuff
          taglib
          xfce.tumbler
          gnome-epub-thumbnailer
          webp-pixbuf-loader
          poppler
          ffmpegthumbnailer
          haskellPackages.freetype2
        ];

        services.gammastep = {
          enable = true;
          latitude = secrets.common.latitude;
          longitude = secrets.common.longitude;
          tray = true;
          settings.general.brightness-day = 1.0;
          settings.general.brightness-night = 0.7;
        };

        services.udiskie = {
          enable = true;
          automount = false;
          notify = true;
        };

        fonts.fontconfig.enable = true;

        home.pointerCursor = {
          x11.enable = true;
          gtk.enable = true;
          package = pkgs.catppuccin-cursors.macchiatoDark;
          name = "catppuccin-macchiato-dark-cursors";
          size = 32;
        };

        xdg.configFile."alacritty/alacritty.toml".source =
          ../../../dotfiles/alacritty.toml;

        dconf.enable = true;
        gtk = {
          enable = true;
          font = {
            name = "FiraCode";
            size = 10;
          };
          iconTheme = {
            package = pkgs.papirus-icon-theme;
            name = "Papirus-Dark";
          };
          theme = {
            package = pkgs.gnome-themes-extra;
            name = "Adwaita";
          };
          cursorTheme = {
            package = pkgs.catppuccin-cursors.macchiatoDark;
            name = "catppuccin-macchiato-dark-cursors";
            size = 32;
          };
          gtk3.extraConfig = {gtk-application-prefer-dark-theme = 1;};
          gtk4.extraConfig = {gtk-application-prefer-dark-theme = 1;};
        };
        qt = {
          enable = true;
          #style.package = pkgs.adwaita-qt;
          style.name = "breeze";
        };

        services.dunst = {
          enable = true;
          settings = {
            global = {
              width = "(0,300)";
              height = "(0,150)";
              notification_limit = 5;
              offset = "20x20";
              font = "Hack Nerd Font 10";
              frame_width = 1;
              gap_size = 2;
              #idle_treshold = 30;
              format = "<b>%s</b>\\n%b\\n%p";
              corner_radius = 3;
            };
            urgency_critical = {
              #timeout = 9999;
              background = "#1d2021";
              foreground = "#fbf1c7";
              highlight = "#fe8019";
              frame_color = "#cc241d";
            };
            urgency_normal = {
              timeout = 20;
              background = "#3c3836";
              foreground = "#fbf1c7";
              highlight = "#ebdbb2";
              frame_color = "#665c54";
            };
            urgency_low = {
              timeout = 7;
              background = "#282828";
              foreground = "#a89984";
              highlight = "#bdae93";
              frame_color = "#32302f";
            };
          };
        };

        #TODO: configure correctly, it is now using j for scrolling down
        xdg.configFile."warpd/config".source = ../../../dotfiles/warpd/config;
      })
    #nixos
    else
      (lib.mkIf (cfg.windowSystem != "none") {
        environment.systemPackages = with pkgs; [
          alacritty
          brightnessctl
        ];
        fonts = {fontconfig = {subpixel.rgba = "none";};};
        xdg.portal.enable = true;
        xdg.portal.xdgOpenUsePortal = true;
      });
}
