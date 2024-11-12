{
  lib,
  flake_inputs,
  ...
}: let
  #fileOverlay = path: final: prev: (import path {inherit final prev flake_inputs lib;});
  fileOverlay = path: final: prev: (import path {
    inherit flake_inputs lib;
    pkgsPrev = prev;
    pkgsFinal = final;
  });
in
  map fileOverlay
  [
    #TODO for now old.nix contains all overlays, they can be moved out here
    ./old.nix
    ./ccache.nix
    ./enchilada/default.nix
    #TODO rename if this is successful
    ./enchilada/installer_standalone.nix
  ]
