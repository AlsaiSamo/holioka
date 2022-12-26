{lib, pkgs, config, ...}:

{
    home.packages = with pkgs; [
        i3-gaps
        alacritty
        xdotool
        maim
        ];
#TODO i3-gaps doesn't understand gaps???
#yoooo, i3 without gaps
#I don't depend on gaps anyways

    xdg.configFile."i3/config".source = ../dotfiles/i3/config;
    xdg.configFile."alacritty/alacritty.yml".source = ../dotfiles/alacritty.yml;

    services.betterlockscreen = {
        enable = true;
        inactiveInterval = 5;
        arguments = ["blur" "0.5"];
    };
    services.picom = {
        enable = true;
        shadow = false;
        fade = true;
        fadeDelta = 2;
        fadeExclude = ["x = 0 && y = 0 && override_redirect = true"];

        inactiveOpacity = 1.0;
        menuOpacity = 1.0;
        activeOpacity = 1.0;
        opacityRules = [
            "95:class_g = 'Alacritty' && !focused"
        ];
#blur = true;
        vSync = true;
    };
    home.persistence."/state/home/imikoy" = {
        directories = [
            ".cache/betterlockscreen"
        ];
    };
}
