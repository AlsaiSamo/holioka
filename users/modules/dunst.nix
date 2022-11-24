{lib, pkgs, ...}:

{
    services.dunst = {
        enable = true;
        settings = {
            global = {
                geometry = "300x5-30+20";
                font = "Iosevka 10";
            };
        };
    };
}
