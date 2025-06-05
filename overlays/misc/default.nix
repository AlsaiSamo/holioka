{
  pkgsPrev,
  pkgsFinal ? pkgsPrev,
  lib,
  flake_inputs,
}:
#This file is for patches or easy changes.
rec {
  atuin = pkgsPrev.atuin.overrideAttrs (old: {
    patches =
      (old.patches or [])
      ++ [
        ./ZFS.patch
      ];
  });
  fish = pkgsPrev.fish.overrideAttrs (old: {
    patches =
      (old.patches or [])
      ++ [
        ./fish-complete-and-search-proper.patch.rust
      ];
  });

  #The limit originally is 1024, which makes emacs hit "too many open files".
  emacsPGTK_FD = pkgsPrev.emacs-pgtk.overrideAttrs (old: {
    configureFlags = (old.configureFlags or []) ++ ["CFLAGS=-DFD_SETSIZE=31000"];
  });
  emacs_FD = pkgsPrev.emacs.overrideAttrs (old: {
    configureFlags = (old.configureFlags or []) ++ ["CFLAGS=-DFD_SETSIZE=31000"];
  });
}
