{ lib, config, pkgs, secrets, extra, modulesPath, ... }@inputs: {
  imports =
    [
      ./hardware.nix
      ../../modules/nixos/audio.nix
      ../../modules/nixos/x.nix
      ../../modules/nixos/common.nix
      ../../modules/nixos/avahi.nix
      ../../modules/nixos/sshd.nix
      ../../modules/nixos/imikoy.nix
      ../../modules/nixos/flatpak.nix
    ];

  defaultFilesystems = true;
  stateRemoval.enable = true;
  backup.enable = true;

  programs.ssh.knownHosts = {
    hlkeast = {
      publicKeyFile = ../../secrets/east/ssh_host_ed25519_key.pub;
    };
  };

  users.users.root.openssh.authorizedKeys.keyFiles = [
    ../../secrets/east/ssh_host_ed25519_key.pub
    ../../secrets/east/ssh_host_rsa_key.pub
  ];

  services.avahi.allowInterfaces = ["eno1"];

  #nixpkgs.config.allowUnfree = lib.mkForce true;

  nix.settings.cores = 11;
  networking = {
    hostName = secrets.west.hostName;
    hostId = secrets.west.hostId;
    nftables.enable = true;
    networkmanager.enable = true;
  };
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
