{
  config,
  lib,
  pkgs,
  secrets,
  ...
} @ inputs: {
  imports = [
    ./fs.nix
    ./audio.nix
    ./flatpak.nix
    ./virt.nix
    ./network.nix
    ./sshd.nix
    ./user.nix
    ./graphical
    ./jp.nix
    ./distributed.nix
    ./avahi.nix
    ./barrier.nix
    ./ccache.nix
  ];
}
