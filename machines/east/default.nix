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
    # sshd.default.enable = true;
    xserver.default.enable = true;
    mainUser = {
      default.enable = true;
    };
    jp.enable = true;
  };

  #TODO: automate this when doing SSH
  users.users.root.openssh.authorizedKeys.keyFiles = [
    ../../secrets/west/ssh_host_ed25519_key.pub
    ../../secrets/west/ssh_host_rsa_key.pub
  ];

  nix.settings.cores = 3;
  time.timeZone = secrets.common.timeZone;

  environment.systemPackages = with pkgs; [
    wineWowPackages.stable
    qemu
    alacritty
    redshift

    blueberry
  ];

  system.stateVersion = "23.11";
}
