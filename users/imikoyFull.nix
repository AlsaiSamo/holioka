{
  # osConfig,
  flake_inputs,
  pkgs,
  config,
  lib,
  hmModules,
  hmOverlay,
  userName,
  extraUserConfig,
  ...
}:
#TODO: remove
{
  _module.args.userName = userName;
  nixpkgs.overlays = hmOverlay;
  imports = hmModules;
  programs.home-manager.enable = true;

  nixpkgs.config.permittedInsecurePackages = [
    "olm-3.2.16"
  ];
  #FIX: matrix is a broken mess (libolm is deprecated and is used by most clients)
  #find a way to not have to use libolm
  programs.nheko.enable = true;
  home.packages = with pkgs; [
    blueberry
    cmus
    krita

    ffmpeg-full
    yt-dlp

    alejandra

    #TODO work stuff
    #TODO: move out to its own module
    #TODO: persist state
    thunderbird
    zoom-us
    telegram-desktop
    libreoffice
    dbeaver-bin
    wineWowPackages.stable
  ];

  hlk = {
    cli.default.enable = true;
    emacs.default.enable = true;
    firefox.default.enable = true;
    wine.enable = true;
    games = {
      osu.state.enable = true;
      xonotic.state.enable = true;
      # xonotic.enable = true;
    };
    gpg.default.enable = true;
    graphical.windowSystem = "xorg";
    nvim.default.enable = true;
    krita.enable = true;
    vmTools.enable = false;
  };

  home.persistence."/state/home/${userName}" = {
    allowOther = true;
    files = [
      ".config/kritarc"
      ".config/kritashortcutrc"

      #FIX: work stuff, move to its own module
      ".config/zoom.conf"
      ".config/zoomus.conf"
    ];
    directories = [
      #Never used it
      #"Scripts"
      "Desktop"
      "Documents"
      #Was persisted before, not now
      #"Downloads"
      #TODO: refresh music library
      "Music"
      "Pictures"
      "Projects"
      #random downloaded things
      "litter"

      #TODO: work stuff, move to its own module
      ".thunderbird"
      ".local/share/TelegramDesktop"
      #FIX: these are new, move them first
      ".cache/zoom"
      ".config/menus"
      ".config/libreoffice"
      ".local/share/applications/wine"
      ".local/share/DBeaverData"
      ".local/share/mime"
      ".wine"
      ".zoom"

      #TODO: an nheko module
      ".cache/nheko"
      ".config/nheko"
      ".local/share/nheko"

      ".local/state/wireplumber"

      ".config/cmus"
    ];
  };

  home.stateVersion = "23.11";
}
// extraUserConfig
