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
    # avahi.default.enable = true;
    virt.default.enable = true;
    network = {
      default.enable = true;
      desktop.enable = true;
      hostName = "east";
    };
    sshd.default.enable = true;
    nix.distributed.enable = true;
    xserver.default.enable = true;
    mainUser = {
      default.enable = true;
    };
    jp.enable = true;
  };

  #TODO: automate this when doing SSH
  users.users.root.openssh.authorizedKeys.keyFiles = secrets.east.authorizedKeyFiles;

  nix.settings.cores = 3;
  time.timeZone = secrets.common.timeZone;

  environment.systemPackages = with pkgs; [
    wineWowPackages.stable
    qemu
    alacritty

    blueberry
  ];

  system.stateVersion = "23.11";
}
