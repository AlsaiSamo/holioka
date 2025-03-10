select_user: {
  config,
  lib,
  pkgs,
  userName,
  ...
}:
#TODO: add all of the things when migrating to West
let
  cfg = config._hlk_auto.work;
  options._hlk_auto.work = {
    enable = lib.mkEnableOption "config options";
  };
in {
  inherit options;
  config =
    if select_user
    #hm
    then
      lib.mkIf cfg.enable {
        #TODO: turn into a list of package names, then define the predicate function when processing the options that works with the merged list
        nixpkgs.config.allowUnfree = true;
        home.packages = with pkgs; [
          thunderbird
          zoom-us
          telegram-desktop
          libreoffice
          dbeaver-bin
          wineWowPackages.stable
        ];
        home.persistence."/state/home/${userName}" = {
          allowOther = true;
          files = [
            ".config/zoom.conf"
            ".config/zoomus.conf"
          ];
          directories = [
            ".thunderbird"
            ".local/share/TelegramDesktop"
            ".cache/zoom"
            ".config/menus"
            ".config/libreoffice"
            ".local/share/applications/wine"
            ".local/share/DBeaverData"
            ".local/share/mime"
            ".wine"
            ".zoom"
          ];
        };
      }
    #nixos
    else {};
}
