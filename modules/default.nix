{
  config,
  lib,
  pkgs,
  secrets,
  ...
} @ inputs: {
  imports = [
    ./util/avahi.nix
    ./nixos/fs.nix
    ./nixos/audio.nix
    ./nixos/flatpak.nix
    ./nixos/virt.nix
    ./nixos/network.nix
    ./nixos/sshd.nix
    ./nixos/user.nix
    ./nixos/x.nix
    ./nixos/jp.nix
  ];
}
