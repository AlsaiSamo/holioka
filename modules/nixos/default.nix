{
  config,
  lib,
  pkgs,
  secrets,
  ...
} @ inputs: {
  imports = [
    ./common.nix
    ./fs.nix
    ./audio.nix
    ./flatpak.nix
    ./virt.nix
    ./network.nix
    ./sshd.nix
    ./user.nix
    ./graphical
    ./fcitx.nix
    ./distributed.nix
    ./avahi.nix
    ./barrier.nix
    ./user_rewrite.nix
  ];
}
