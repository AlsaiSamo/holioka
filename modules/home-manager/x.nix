{
  flake_inputs,
  lib,
  pkgs,
  config,
  secrets,
  ...
}: {
  home.packages = with pkgs; [
    (nerdfonts.override {fonts = ["FiraCode" "Iosevka" "Hack"];})
    mpv
    xawtv
    #TODO: patch with nerd font and use everywhere
    sarasa-gothic
    noto-fonts-color-emoji   
    font-awesome
    i3
    feh
    rofi-power-menu
    #Requires the user to be in "video" group
    light
    warpd
    xclip
    alacritty
    xdotool
    shotgun
    hacksaw
    imagemagick
    dconf
    keepassxc
    pcmanfm
    poppler
    ffmpegthumbnailer
    haskellPackages.freetype2
  ];

  fonts.fontconfig.enable = true;

  home.pointerCursor = {
    x11.enable = true;
    gtk.enable = true;
    package = pkgs.catppuccin-cursors.macchiatoDark;
    name = "catppuccin-macchiato-dark-cursors";
    size = 32;
  };

  xdg.configFile."i3/config".source = ../../dotfiles/i3/config;
  xdg.configFile."alacritty/alacritty.toml".source =
    ../../dotfiles/alacritty.toml;

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
      package = pkgs.gnome.gnome-themes-extra;
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

  services.polybar = {
    enable = true;
    package = pkgs.polybarFull;
    config = ../../dotfiles/polybar/config.ini;
    script = ''
      pkill polybar
      #All monitor names, the ones that don't exist will simply not launch
      #TODO: monitor name on West with AMD
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

  services.betterlockscreen = {
    enable = true;
    inactiveInterval = 5;
    arguments = ["blur" "0.5"];
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

  services.gammastep = {
    enable = true;
    latitude = secrets.common.latitude;
    longitude = secrets.common.longitude;
    tray = true;
    settings.general.brightness-day = 1.0;
    settings.general.brightness-night = 0.7;
  };

  #TODO: take fcitx (and ibus and mozc) and anki stuff out
  home.persistence."/state/home/imikoy" = {
    directories = [
      ".cache/betterlockscreen"

      ".config/fcitx5"
      #Appears when adding something like quick phrase
      ".local/share/fcitx5"
      ".config/mozc"
      ".local/share/Anki2"
    ];
    files = [
      ".cache/rofi3.druncache"
      ".config/keepassxc/keepassxc.ini"
      ".cache/keepassxc/keepassxc.ini"
      ".config/warpd/config"
    ];
  };
}
