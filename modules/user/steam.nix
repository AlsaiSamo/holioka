select_user:
{
  config,
  lib,
  pkgs,
  userName,
  ...
}:
#NOTE: games are stored in ~/large_items, they must not be snapshotted
let
  cfg = config._hlk_auto.steam;
  options._hlk_auto.steam = {
    enable = lib.mkEnableOption "Steam";
  };
in
{
  inherit options;
  config =
    if
      select_user
    #hm
    then
      {
        #TODO: bindmount ~/large_items/Steam to ~/.local/share/Steam
        #but in a way that'll work (so that it'll be owned by the mainuser)
        #TODO: look at zfs diffs
      }
    #nixos
    else
      lib.mkIf cfg.enable {
        programs.steam = {
          enable = true;
          extraPackages = with pkgs; [
            gamescope
            gamemode
          ];
          protontricks.enable = true;
          # extraCompatPackages = with pkgs; [];
          # package = pkgs.steam.override {};
        };
      };
}
