{ config, lib, pkgs, secrets, ... }@inputs:

{
  users.mutableUsers = false;
  users.groups.imikoy.gid = 1000;
  users.users.imikoy = {
    hashedPassword = secrets.common.userHashedPassword;
    isNormalUser = true;
    group = "imikoy";
    shell = pkgs.zsh;
    extraGroups =
      [ "wheel" "realtime" "pipewire" "jackaudio" "libvirt" "audio" "video" ];
  };
}
