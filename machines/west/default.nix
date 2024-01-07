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

  # programs.ssh.knownHosts = {
  #   hlkeast = { publicKeyFile = ../../secrets/east/ssh_host_ed25519_key.pub; };
  # };

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

  # services.avahi.allowInterfaces = [ "eno1" ];

  #nixpkgs.config.allowUnfree = lib.mkForce true;

  nix.settings.cores = 11;
  time.timeZone = secrets.common.timeZone;

  environment.systemPackages = with pkgs; [
    jq
    wineWowPackages.stable
    qemu
    alacritty
    gvfs
    nixd
    redshift
  ];

  system.stateVersion = "23.11";
}
