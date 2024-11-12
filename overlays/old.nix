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
        ./ZFS.patch
      ];
  });

  #The limit originally is 1024, which makes emacs hit "too many open files".
  emacsPGTK_FD = pkgsPrev.emacs29-pgtk.overrideAttrs (old: {
    configureFlags = (old.configureFlags or []) ++ ["CFLAGS=-DFD_SETSIZE=10000"];
  });
  emacs_FD = pkgsPrev.emacs.overrideAttrs (old: {
    configureFlags = (old.configureFlags or []) ++ ["CFLAGS=-DFD_SETSIZE=10000"];
  });

  #ccachePkgs = import ./ccache.nix {inherit pkgsPrev pkgsFinal lib flake_inputs;};
}
#// (import ./enchilada/default.nix {inherit pkgsPrev pkgsFinal lib flake_inputs;})

