{
  pkgsPrev,
  pkgsFinal ? pkgsPrev,
  lib,
  flake_inputs,
}: rec {
  sway_mobile = pkgsPrev.sway.overrideAttrs (old: {
    patches =
      (old.patches or [])
      ++ [
        ./allow-other.patch
        ./0003-mobile-swaybar-bottom-overlay-layer.patch
        ./0001-mobile-don-t-idle_notify-for-volume-keys.patch
        ./0004-mobile-dont-occupy-exclusive-layers-with-fullscreen.patch
      ];
  });
}
