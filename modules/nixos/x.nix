{ config, lib, pkgs, ... }@inputs: {
  services.xserver = {
    xkbOptions = "grp:caps_toggle";
    autoRepeatDelay = 200;
    autoRepeatInterval = 30;
    enable = true;
    layout = "us,ru";
    displayManager = {
      defaultSession = "none+i3";
      autoLogin.user = "imikoy";
    };
    windowManager.i3.enable = true;
  };
  #TODO: use sarasa-gothic (patched with nerdfonts)
  fonts = { fontconfig = { subpixel.rgba = "none"; }; };
}
