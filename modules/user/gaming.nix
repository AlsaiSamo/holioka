select_user:
{
  config,
  lib,
  pkgs,
  userName,
  ...
}:
let
  cfg = config._hlk_auto.games;
  options._hlk_auto.games = {
    #NOTE: currently not playing osu.
    osu.state.enable = lib.mkEnableOption "osu! state preservation";
    xonotic.state.enable = lib.mkEnableOption "Xonotic state preservation";
    xonotic.enable = lib.mkEnableOption "Xonotic";
    terraria.state.enable = lib.mkEnableOption "Terraria state preservation";
  };
in
{
  inherit options;
  config =
    if
      select_user
    #hm
    then
      lib.mkMerge [
        (lib.mkIf cfg.xonotic.enable {
          home.packages = [ pkgs.xonotic ];
        })
      ]
    #nixos
    else
      lib.mkMerge [
        (lib.mkIf cfg.osu.state.enable {
          environment.persistence."/local_state".users.${userName}.directories = [
            ".local/share/osu"
          ];
        })
        (lib.mkIf cfg.xonotic.state.enable {
          environment.persistence."/local_state".users.${userName}.directories = [
            ".xonotic"
          ];
        })
        (lib.mkIf cfg.terraria.state.enable {
          environment.persistence."/local_state".users.${userName}.directories = [
            ".local/share/Terraria"
          ];
        })
      ];
}
