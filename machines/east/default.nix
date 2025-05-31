inputs @ {
  lib,
  config,
  pkgs,
  secrets,
  extra,
  modulesPath,
  ...
}: {
  hlk = {
    common.enable = true;
    defaultFilesystems = true;
    stateRemoval.enable = true;
    backup.enable = true;
    flatpak.default.enable = true;
    audio = {
      default.enable = true;
      desktop.enable = true;
    };
    virt.default.enable = true;
    network = {
      manager = "iwd";
      hostName = "east";
    };
    sshd = {
      default.enable = true;
      rootKeysFrom = secrets.east.authorizedKeyFiles;
    };
    #TODO: currently cannot connect the two machines
    #nix.distributed.enable = true;
    mainUserRewrite = {
      enable = true;
      userName = "imikoy";
      userConfig = {
        games = {
          osu.state.enable = false;
          xonotic.enable = false;
          xonotic.state.enable = false;
        };
        cli.core.enable = true;
        cli.extra.enable = true;
        cli.shell = "fish";
        cli.starship.enable = true;
        #TODO: disabled for faster iteration (this needs to build Emacs for evaluation)
        #emacs.default.enable = true;
        firefox.default.enable = true;
        gpg.default.enable = true;
        graphical.windowSystem = "wayland";
        nvim.default.enable = true;
        krita.enable = true;
        fcitx.enable = true;
        nheko.enable = true;
        work.enable = false;
        common.enable = true;
        keepass.enable = true;
      };
    };
  };

  system.stateVersion = "23.11";
}
