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

  # programs.ssh = {
  #   knownHosts = {
  #     hlkwest = {
  #       publicKeyFile = ../../secrets/west/ssh_host_ed25519_key.pub;
  #     };
  #   };
  #   #TODO: i have to make the network nuuuuuuu
  #   extraConfig = ''
  #     #This allows using root to log in as root
  #     #AddKeysToAgent will probably not work with non-root ssh agent
  #           Host 192.168.0.185
  #           IdentityFile /state/secrets/ssh/ssh_host_ed25519_key
  #   '';
  # };

  #TODO: automate this when doing SSH
  users.users.root.openssh.authorizedKeys.keyFiles = [
    ../../secrets/west/ssh_host_ed25519_key.pub
    ../../secrets/west/ssh_host_rsa_key.pub
  ];

  nix.settings.cores = 3;
  # networking = {
  #   hostName = secrets.east.hostName;
  #   hostId = secrets.east.hostId;
  #   nftables.enable = true;
  #   networkmanager.enable = true;
  # };
  time.timeZone = secrets.common.timeZone;

  environment.systemPackages = with pkgs; [
    wineWowPackages.stable
    alacritty
    blueberry
  ];

  system.stateVersion = "23.11";
}
