{
  config,
  lib,
  pkgs,
  ...
}: {
  #NOTE restarting sway will not restart other services, to fix this it is required
  #to restart other services in sway's config.
  #Explanation:
  #https://discourse.nixos.org/t/sway-via-home-manager-startup-and-tray-services/45930
  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    systemd.enable = true;
  };
  #TODO
  #1. Have to start sway from the tty,
  #2. Need to get a bar
  #
  #Issues:
  #1. Need to autostart
  #2. Need a bar
  #3. Need to fix DPI in alacritty
  #4. Need warpd
  #5. Need to write proper sway config
  #6. Configure rofi or alternative
  #7. Should not die on C-c
}
