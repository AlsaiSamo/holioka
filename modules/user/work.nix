select_user:
{
  config,
  lib,
  pkgs,
  userName,
  secrets,
  ...
}:
let
  cfg = config._hlk_auto.work;
  options._hlk_auto.work = {
    enable = lib.mkEnableOption "config options";
  };
in
{
  inherit options;
  config =
    if
      select_user
    #hm
    then
      lib.mkIf cfg.enable {
        #TODO: turn into a list of package names, then define the predicate function when processing the options that works with the merged list
        nixpkgs.config.allowUnfree = true;
        home.packages =
          with pkgs;
          [
            thunderbird
            zoom-us
            telegram-desktop
            libreoffice
            dbeaver-bin
            unixtools.route
          ]
          ++ (
            if (config._hlk_auto.graphical.desktopVariant == "xorg") then
              [
                wineWow64Packages.stable
              ]
            else
              [ ]
          )
          ++ (
            if (config._hlk_auto.graphical.desktopVariant == "wayland") then
              [
                wineWow64Packages.wayland
              ]
            else
              [ ]
          );
      }
    #nixos
    else
      lib.mkIf cfg.enable {
        services.openvpn.servers.work = {
          updateResolvConf = true;
          config = secrets.work.vpn_conf;
        };
        environment.systemPackages = with pkgs; [
          openvpn
        ];
        environment.persistence."/state".users.${userName} = {
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
      };
}
