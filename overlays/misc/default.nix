{
  pkgsPrev,
  pkgsFinal ? pkgsPrev,
  lib,
  flake_inputs,
}:
#This file is for patches or easy changes.
{
  atuin = pkgsPrev.atuin.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      ./ZFS.patch
    ];
  });
  fish_patched = pkgsPrev.fish.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      ./fish-complete-and-search-proper.patch.rust
    ];
  });

}
