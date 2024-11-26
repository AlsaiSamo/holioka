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
      default.enable = true;
      desktop.enable = true;
      hostName = "east";
    };
    sshd = {
      default.enable = true;
      rootKeysFrom = secrets.east.authorizedKeyFiles;
    };
    nix.distributed.enable = true;
    graphical.windowSystem = "xorg";
    mainUser = {
      default.enable = true;
      extraUserConfig = {
        hlk.games = {
          osu.state.enable = false;
          xonotic.enable = false;
          xonotic.state.enable = false;
        };
        #TODO: disable a bunch of stuff after adding modules
      };
    };
    fcitx.enable = false;
  };

  system.stateVersion = "23.11";
}
