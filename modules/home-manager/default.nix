{
  lib,
  config,
  pkgs,
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
  ];
  #TODO: move messaging out
  #also use fluffychat and look into configuring nheko here
  home.packages = with pkgs; [fluffychat cmus xonotic];
  programs.nheko.enable = true;
  home.persistence."/state/home/imikoy" = {
    files = [];
    directories = [
      ".cache/nheko"
      ".config/nheko"
      ".local/share/nheko"

      ".local/state/wireplumber"

      ".config/cmus"
    ];
  };
  home.persistence."/local_state/home/imikoy" = {
    directories = [
      #Big.
      ".xonotic"
      ".local/share/osu"
    ];
  };
}
