{
  userName,
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.hlk.games;
in {
  options.hlk.games = {
    osu.state.enable = lib.mkEnableOption "osu! state preservation";
    xonotic.state.enable = lib.mkEnableOption "Xonotic state preservation";
    xonotic.enable = lib.mkEnableOption "Xonotic";
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.osu.state.enable {
      home.persistence."/local_state/home/${userName}".directories = [
        ".local/share/osu"
      ];
    })
    (lib.mkIf cfg.xonotic.enable {
      home.packages = [pkgs.xonotic];
    })
    (lib.mkIf cfg.xonotic.state.enable {
      home.persistence."/local_state/home/${userName}".directories = [
        ".xonotic"
      ];
    })
  ];
}
