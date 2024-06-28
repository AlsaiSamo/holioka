inputs @ {
  lib,
  config,
  pkgs,
  secrets,
  extra,
  modulesPath,
  ...
}: {
  imports = [
    ./hardware.nix
    ../../modules/nixos/common.nix
  ];

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
      root_keys_from = secrets.east.authorizedKeyFiles;
    };
    nix.distributed.enable = true;
    xserver.default.enable = true;
    mainUser = {
      default.enable = true;
    };
    jp.enable = false;
  };

  system.stateVersion = "23.11";
}
