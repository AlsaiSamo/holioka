{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.hlk.jp;
in {
  options.hlk.jp = {
    enable = lib.mkEnableOption "tools for learning JP";
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
      # anki-bin
    ];
  };
}
