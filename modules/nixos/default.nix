{
  config,
  lib,
  pkgs,
  secrets,
  ...
}@inputs:
{
  #NOTE: I always create the main user, so these modules may not be maintained as good as the usermodules.
  imports = [
    ./common.nix
    ./fs.nix
    ./audio.nix
    ./flatpak.nix
    ./virt.nix
    ./network.nix
    ./sshd.nix
    ./graphical
    ./distributed.nix
    ./avahi.nix
    ./user.nix
  ];
}
