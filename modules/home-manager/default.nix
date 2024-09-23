{
  lib,
  config,
  pkgs,
  userName,
  extraUserConfig,
  ...
} @ inputs: {
  imports = [
    ./cli.nix
    ./graphical/default.nix
    ./gpg.nix
    ./firefox.nix
    ./nvim.nix
    ./emacs.nix
    ./gaming.nix
    ./wine.nix
    ./vm_extra.nix
    ./krita.nix
  ];
}
