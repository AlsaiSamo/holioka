{
  flake_inputs,
  lib,
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [
    (nerdfonts.override {fonts = ["FiraCode" "Iosevka" "Hack"];})
    mpv
    xawtv
    #TODO: patch with nerd font and use everywhere
    sarasa-gothic
    i3
    feh
    rofi-power-menu
    #Requires the user to be in "video" group
    light
    warpd
    maim
    xclip
    alacritty
    xdotool
    maim
    dconf
    keepassxc
    libsecret
    udiskie
    pcmanfm
    gvfs
    ntfs3g
    poppler
    ffmpegthumbnailer
    haskellPackages.freetype2
    libnotify
  ];

  fonts.fontconfig.enable = true;

  home.pointerCursor = {
    name = "phinger-cursors";
    package = pkgs.phinger-cursors;
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
    gtk3.extraConfig = {gtk-application-prefer-dark-theme = 1;};
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

  #TODO: use osConfig to determine monitors and backlight
  services.polybar = {
    enable = true;
    package = pkgs.polybar.override {
      i3Support = true;
      pulseSupport = true;
      mpdSupport = true;
    };
    config = ../../dotfiles/polybar/config.ini;
    script = ''
      pkill polybar
      echo "---" | tee -a /tmp/polybar1.log /tmp/polybar2.log
      polybar default 2>&1 | tee -a /tmp/polybar1.log & disown
      polybar extra 2>&1 | tee -a /tmp/polybar2.log & disown

      echo "Bars launched..."
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
