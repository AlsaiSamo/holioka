{
  pkgsPrev,
  pkgsFinal ? pkgsPrev,
  lib,
  flake_inputs,
}:
#TODO: move the file to the sway directory
rec {
  sway_mobile = pkgsPrev.sway.overrideAttrs (old: {
    patches =
      (old.patches or [])
      ++ [
        ./sway/allow-other.patch
        ./sway/0003-mobile-swaybar-bottom-overlay-layer.patch
        ./sway/0001-mobile-don-t-idle_notify-for-volume-keys.patch
        ./sway/0004-mobile-dont-occupy-exclusive-layers-with-fullscreen.patch
      ];
  });
}
