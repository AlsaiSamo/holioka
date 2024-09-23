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
{
  _module.args.userName = userName;
  nixpkgs.overlays = [hmOverlay];
  imports = hmModules;
  programs.home-manager.enable = true;

  #TODO: matrix is a broken mess (libolm is deprecated and is used by most clients)
  #programs.nheko.enable = true;
  #TODO: move things out into modules
  home.packages = with pkgs; [
    blueberry
    # fluffychat
    cmus
    krita

    ffmpeg-full
    # tartube
    yt-dlp

    alejandra

    thunderbird
    zoom-us
    telegram-desktop
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
    ];
    directories = [
      #Never used it
      #"Scripts"
      "Desktop"
      "Documents"
      #Was persisted before, not now
      #"Downloads"
      "Music"
      "Pictures"
      "Projects"

      ".thunderbird"
      ".local/share/TelegramDesktop"

      #TODO: move out into modules
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
