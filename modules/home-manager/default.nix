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
    ./gpg.nix
    ./x.nix
    ./firefox.nix
    ./nvim.nix
    ./emacs.nix
    ./programming.nix
    ./gaming.nix
  ];
}
