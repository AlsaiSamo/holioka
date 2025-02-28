select_user: {
  config,
  lib,
  pkgs,
  userName,
  ...
}:
#TODO: have osu (when ported to West)
let
  cfg = config._hlk_auto.games;
  options._hlk_auto.games = {
    osu.state.enable = lib.mkEnableOption "osu! state preservation";
    xonotic.state.enable = lib.mkEnableOption "Xonotic state preservation";
    xonotic.enable = lib.mkEnableOption "Xonotic";
  };
in {
  inherit options;
  config =
    if select_user
    #hm
    then
      lib.mkMerge [
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
      ]
    #nixos
    else {};
}
