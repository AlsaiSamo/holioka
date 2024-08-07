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

  #Learning
  services.postgresql = {
    enable = true;
    ensureDatabases = [
      "learning"
    ];
    authentication = pkgs.lib.mkOverride 10 ''
      #type database  DBuser  auth-method
      local all       all     trust
      host  all       postgres 127.0.0.1/32 trust
    '';
  };

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



  system.stateVersion = "23.11";
}
