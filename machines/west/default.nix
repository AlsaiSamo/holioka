{
  lib,
  config,
  pkgs,
  secrets,
  extra,
  modulesPath,
  ...
} @ inputs: {
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
      lowLatency.enable = true;
    };
    virt.default.enable = true;
    network = {
      default.enable = true;
      desktop.enable = true;
      hostName = "west";
    };
    sshd = {
      default.enable = true;
      root_keys_from = secrets.west.authorizedKeyFiles;
    };
    xserver.default.enable = true;
    mainUser = {
      default.enable = true;
    };
    jp.enable = true;
  };

  services.openvpn.servers.work = {
    updateResolvConf = true;
    config = secrets.work.vpn_conf;
  };
  environment.systemPackages = with pkgs; [
    openvpn
  ];


  system.stateVersion = "23.11";
}
