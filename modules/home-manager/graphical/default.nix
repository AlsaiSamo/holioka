{
  flake_inputs,
  lib,
  pkgs,
  config,
  secrets,
  ...
}: let
  cfg = config.hlk.graphical;
in {
  imports = [./x.nix ./wayland.nix];
  options.hlk.graphical = {
    windowSystem = lib.mkOption {
      example = "xorg";
      description = "What windowing system and the respective environment to enable for the user";
      default = "none";
      type = lib.types.enum ["none" "xorg" "wayland"];
    };
  };
  config = lib.mkIf (cfg.windowSystem
    != "none") {
    #TODO: enable different things under xorg and wayland, and enable common things
    #when either is defined
    home.packages = with pkgs; [
      dconf

      sarasa-gothic
      noto-fonts-color-emoji
      font-awesome
      (nerdfonts.override {fonts = ["FiraCode" "Iosevka" "Hack"];})

      alacritty
      warpd
      mpv
      feh
      keepassxc

      pcmanfm
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
      style.package = pkgs.adwaita-qt;
    };

    services.dunst = {
      enable = true;
      settings = {
        global = {
          geometry = "300x5-30+20";
          font = "Iosevka NFM";
        };
      };
    };

    services.betterlockscreen = {
      enable = true;
      inactiveInterval = 5;
      arguments = ["blur" "0.5"];
    };

    xdg.configFile."warpd/config".source = ../../../dotfiles/warpd/config;
    #TODO: fcitx stuff (including mozc) should be its own module
    home.persistence."/state/home/imikoy" = {
      directories = [
        ".config/fcitx5"
        #Appears when adding something like quick phrase
        ".local/share/fcitx5"
        ".config/mozc"
      ];
      files = [
        ".config/keepassxc/keepassxc.ini"
        ".cache/keepassxc/keepassxc.ini"
      ];
    };
  };
}
