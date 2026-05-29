inputs@{
  lib,
  config,
  pkgs,
  secrets,
  extra,
  modulesPath,
  ...
}:
{
  hlk = {
    common.enable = true;
    defaultFilesystems = true;
    stateRemoval.enable = true;
    backup.enable = true;
    # flatpak.default.enable = true;
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
    #nix.distributed.enable = true;
    mainUser = {
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
        emacs.default.enable = true;
        firefox.default.enable = true;
        gpg.default.enable = true;
        graphical.desktopVariant = "wayland";
        nvim.default.enable = true;
        krita.enable = true;
        fcitx.enable = true;
        comms.nheko.enable = true;
        work.enable = false;
        common.enable = true;
        keepass.enable = true;
      };
    };
  };

  system.stateVersion = "23.11";
}
