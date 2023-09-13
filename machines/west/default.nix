{ lib, config, pkgs, secrets, extra, modulesPath, ... }@inputs: {
  imports =
    [
      ./hardware.nix
      ../../modules/nixos/audio.nix
      ../../modules/nixos/x.nix
      ../../modules/nixos/common.nix
      ../../modules/nixos/avahi.nix
      ../../modules/nixos/sshd.nix
    ];

  defaultFilesystems = true;
  stateRemoval.enable = true;

  users.users.root.openssh.authorizedKeys.keyFiles = [
    ../../secrets/east/ssh_host_ed25519_key.pub
    ../../secrets/east/ssh_host_rsa_key.pub
  ];
  #TODO: is this ok?
  users.users.imikoy.openssh.authorizedKeys.keyFiles = [
    ../../secrets/east/ssh_host_ed25519_key.pub
    ../../secrets/east/ssh_host_rsa_key.pub
  ];

  services.avahi.allowInterfaces = ["eno1"];

  nixpkgs.config.allowUnfree = lib.mkForce true;

  nix.settings.cores = 11;
  networking = {
    hostName = secrets.west.hostName;
    hostId = secrets.west.hostId;
    nftables.enable = true;
    networkmanager.enable = true;
  };
  #TODO: nm-applet should be in GUI module
  programs.nm-applet.enable = true;
  time.timeZone = secrets.common.timeZone;

  #TODO: move to hardware
  programs.light.enable = true;
  hardware.nvidia = {
    #Offload is enabled in nixos-hardware module
    #FIX: causes issues. See notes.
    #prime.reverseSync.enable = true;
    prime.sync.enable = lib.mkForce true;
    prime.offload.enable = lib.mkForce false;
    modesetting.enable = true;
    powerManagement.enable = true;
    #will this lead to issues?
    #powerManagement.finegrained = true;
    open = false;
  };

  #TODO: move this out
  #It is common for all machines and other parts of the config may depend on this
  #user existing
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

  system.stateVersion = "23.11";
}
