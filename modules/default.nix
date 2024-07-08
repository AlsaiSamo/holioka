{
  config,
  lib,
  pkgs,
  secrets,
  ...
} @ inputs: {
  imports = [
    ./nixos/fs.nix
    ./nixos/audio.nix
    ./nixos/flatpak.nix
    ./nixos/virt.nix
    ./nixos/network.nix
    ./nixos/sshd.nix
    ./nixos/user.nix
    ./nixos/x.nix
    ./nixos/jp.nix
    ./nixos/distributed.nix
    ./nixos/avahi.nix
    ./nixos/barrier.nix
  ];
}
