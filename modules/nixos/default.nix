{
  config,
  lib,
  pkgs,
  secrets,
  ...
}@inputs:
{
  #WARN: these modules are not going to be maintained well because I do not have
  #      a use case where I do not create my user.
  imports = [
    ./common.nix
    ./fs.nix
    ./audio.nix
    ./flatpak.nix
    ./virt.nix
    ./network.nix
    ./sshd.nix
    ./graphical
    ./fcitx.nix
    ./distributed.nix
    ./avahi.nix
    ./user.nix
  ];
}
