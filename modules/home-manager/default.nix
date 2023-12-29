{
  lib,
  config,
  pkgs,
  userName,
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
  #TODO: move messaging out
  #also use fluffychat and look into configuring nheko here
  home.packages = with pkgs; [fluffychat cmus];
  programs.nheko.enable = true;
  home.persistence."/state/home/${userName}" = {
    files = [];
    directories = [
      ".cache/nheko"
      ".config/nheko"
      ".local/share/nheko"

      ".local/state/wireplumber"

      ".config/cmus"
    ];
  };
}
