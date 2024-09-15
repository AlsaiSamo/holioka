{
  pkgsPrev,
  pkgsFinal ? pkgsPrev,
  lib,
  flake_inputs,
}: {
  atuin = pkgsPrev.atuin.overrideAttrs (old: {
    patches =
      (old.patches or [])
      ++ [
        # ./0001-ZFS.patch
        ./ZFS.patch
      ];
  });

  #The limit originally is 1024, which makes emacs hit "too many open files".
  emacsFDLimit = pkgsPrev.emacs.overrideAttrs (old: {
    configureFlags = (old.configureFlags or []) ++ ["CFLAGS=-DFD_SETSIZE=10000"];
  });
}
