{
  lib,
  flake_inputs,
  ...
}:
let
  fileOverlay =
    path: final: prev:
    (import path {
      inherit flake_inputs lib;
      pkgsPrev = prev;
      pkgsFinal = final;
    });
in
map fileOverlay [
  ./misc
  ./north/enchilada/default.nix
  ./north/spacewar/default.nix
  #TODO: if I end up using sway on north, I should remove this
  ./sway
]
