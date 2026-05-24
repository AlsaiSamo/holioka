select_user:
{
  config,
  lib,
  pkgs,
  userName,
  ...
}:
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
      { }
    #nixos
    else
      lib.mkIf cfg.enable {
        environment.persistence."/local_state".users.${userName} = {
          directories = [ ".local/share/Steam" ];
        };
        programs.steam = {
          enable = true;
          extraPackages = with pkgs; [
            gamescope
          ];
          protontricks.enable = true;
        };
      };
}
