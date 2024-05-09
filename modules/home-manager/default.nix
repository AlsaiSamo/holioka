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
  home.packages = with pkgs; [
    fluffychat
    cmus
    #TODO: move out, along with persistence
    krita
    ffmpeg-full
  ];
  programs.nheko.enable = true;
  home.persistence."/state/home/${userName}" = {
    files = [
      ".config/kritarc"
      ".config/kritashortcutrc"
    ];
    directories = [
      ".cache/nheko"
      ".config/nheko"
      ".local/share/nheko"

      ".local/state/wireplumber"

      ".config/cmus"

      ".local/share/krita"
    ];
  };
}
