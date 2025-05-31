{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.hlk.fcitx;
in
  #TODO: remove this file
  {
    options.hlk.fcitx = {
      enable = lib.mkEnableOption "fcitx";
    };
    config = lib.mkIf cfg.enable {
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
    };
  }
