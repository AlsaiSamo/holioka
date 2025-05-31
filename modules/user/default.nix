select_user: (map (x: import x select_user) [
  ./dummy.nix
  ./cli/default.nix
  ./emacs.nix
  ./firefox.nix
  ./gaming.nix
  ./gpg.nix
  ./krita.nix
  ./nvim.nix
  ./graphical/default.nix
  ./fcitx.nix
  ./nheko.nix
  ./work.nix
  ./common.nix
  ./keepass.nix
  ./network.nix
  #./graphical.nix
])
