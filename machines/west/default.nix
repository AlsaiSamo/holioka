{ lib, config, pkgs, secrets, extra, modulesPath, ... }@inputs: {
  imports =
    [
    ./hardware.nix
    ../../modules/nixos/audio.nix
    ../../modules/nixos/x.nix
    ../../modules/nixos/common.nix
    ];

  defaultFilesystems = true;
  stateRemoval.enable = true;

  nixpkgs.config.allowUnfree = lib.mkForce true;

  nix.settings.cores = 11;
  networking = {
    hostName = secrets.west.hostName;
    hostId = secrets.west.hostId;
    nftables.enable = true;
    networkmanager.enable = true;
  };
  programs.nm-applet.enable = true;
  time.timeZone = secrets.common.timeZone;

  users.mutableUsers = false;
  users.groups = { imikoy = { }; };
  users.users.imikoy = {
    hashedPassword = secrets.common.userHashedPassword;
    isNormalUser = true;
    group = "imikoy";
    shell = pkgs.zsh;
    extraGroups =
      [ "wheel" "realtime" "pipewire" "jackaudio" "libvirt" "audio" "video" ];
  };
  environment.persistence."/state" = {
    files = [ "/etc/machine-id" ];
    directories = [ "/etc/NetworkManager/" ];
  };

  environment.systemPackages = with pkgs; [
    jq
    wineWowPackages.stable
    qemu
    alacritty
    gvfs
    nixd
  ];
  programs.light.enable = true;

  system.stateVersion = "23.11";
}
