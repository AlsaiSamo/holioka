select_user: {
  config,
  lib,
  pkgs,
  userName,
  ...
}: let
  cfg = config._hlk_auto.fcitx;
  options._hlk_auto.fcitx = {
    enable = lib.mkEnableOption "fcitx";
  };
in {
  inherit options;
#TODO: default fcitx config (take from West)
#TODO: fcitx5.settings fro nixos
#TODO: figure ut fcitx on wayland
#TODO: fcitx, wayland, alacritty - fix showing the fcitx popup
  config =
    if select_user
    #hm
    then
      lib.mkIf cfg.enable {
        i18n.inputMethod = {
            enabled = "fcitx5";
            fcitx5.addons = with pkgs; [fcitx5-mozc];
        };
        home.sessionVariables = {
          XMODIFIERS = "@im=fcitx";
          # GTK_IM_MODULE = "fcitx";
          # QT_IM_MODULE = "fcitx";
        };
        home.persistence."/state/home/${userName}" = {
          directories = [
            ".config/fcitx5"
            #Appears when adding something like quick phrase
            ".local/share/fcitx5"
            ".config/mozc"
          ];
        };
      }
    #nixos
    else
      lib.mkIf cfg.enable {
        i18n = {
          inputMethod = {
            type = "fcitx5";
            enable = true;
            fcitx5 = {
              addons = with pkgs; [
                fcitx5-gtk
                libsForQt5.fcitx5-qt
                fcitx5-lua
                fcitx5-mozc
              ];
            };
          };
        };
        environment.systemPackages = with pkgs; [
          fcitx5-configtool
        ];
        environment.variables = {
          XMODIFIERS = "@im=fcitx";
          # GTK_IM_MODULE = "fcitx";
          # QT_IM_MODULE = "fcitx";
        };
      };
}
