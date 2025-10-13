{
  lib,
  config,
  pkgs,
  secrets,
  extra,
  modulesPath,
  ...
}@inputs:
{
  hlk = {
    common.enable = true;
    defaultFilesystems = true;
    stateRemoval.enable = true;
    backup.enable = true;
    flatpak.default.enable = true;
    audio = {
      default.enable = true;
      desktop.enable = true;
      lowLatency.enable = true;
    };
    virt.default.enable = true;
    sshd = {
      default.enable = true;
      rootKeysFrom = secrets.west.authorizedKeyFiles;
    };

    mainUser = {
      enable = true;
      userName = "imikoy";
      userConfig = {
        common.enable = true;
        work.enable = true;
        graphical.windowSystem = "wayland";
        emacs.default.enable = true;
        games = {
          osu.state.enable = true;
          xonotic.enable = true;
          xonotic.state.enable = true;
        };
        cli = {
          core.enable = true;
          extra.enable = true;
          shell = "zsh";
          starship.enable = true;
        };
        network = {
          manager = "iwd";
          hostName = "west";
        };
        firefox.default.enable = true;
        gpg.default.enable = true;
        nvim.default.enable = true;
        krita.enable = true;
        fcitx.enable = true;
        nheko.enable = true;
        keepass.enable = true;
        steam.enable = true;
      };
      extraHmConfig = {
        #TODO: make this work
        # home.persistence."/state/home/imikoy" = {
        #     directories = secrets.west.persistHomeDirs;
        # };
      };
    };
  };
  #TODO: causes ~/.local to be owned by root?
  # environment.persistence."/state".users.imikoy = {
  #     directories = secrets.west.persistHomeDirs;
  # };

  # protracted imikoy's war against adhd
  networking.hosts = {
    "127.0.0.1" = [
      "youtube.com"
      "www.youtube.com"
    ];
  };

  nix.extraOptions = ''
    extra-platforms = aarch64-linux
  '';
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  system.stateVersion = "23.11";
}
