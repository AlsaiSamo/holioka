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
    # avahi.default.enable = true;
    virt.default.enable = true;
    network = {
      default.enable = true;
      desktop.enable = true;
      hostName = "west";
    };
    # sshd.default.enable = true;
    xserver.default.enable = true;
    mainUser = {
      default.enable = true;
    };
    jp.enable = true;
  };

  users.users.root.openssh.authorizedKeys.keyFiles = [
    ../../secrets/east/ssh_host_ed25519_key.pub
    ../../secrets/east/ssh_host_rsa_key.pub
  ];

  nix.settings.cores = 11;
  time.timeZone = secrets.common.timeZone;

  environment.systemPackages = with pkgs; [
    wineWowPackages.stable
    qemu
    alacritty
    redshift
    blueberry

    #work
    zoom-us
  ];

  system.stateVersion = "23.11";
}
