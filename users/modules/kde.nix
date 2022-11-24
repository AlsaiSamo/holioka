{lib, pkgs,...}:

{
    home.packages = with pkgs.libsForQt5; [
        dolphin
        filelight
    ];
}
