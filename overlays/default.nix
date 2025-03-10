{
  lib,
  flake_inputs,
  ...
}: let
  fileOverlay = path: final: prev: (import path {
    inherit flake_inputs lib;
    pkgsPrev = prev;
    pkgsFinal = final;
  });
in
  map fileOverlay
  [
    ./misc.nix
    ./enchilada/default.nix
    ./buffyboard.nix
  ]
