select_user:
{
  config,
  lib,
  pkgs,
  userName,
  ...
}:
let
  cfg = config._hlk_auto.keepass;
  options._hlk_auto.keepass = {
    enable = lib.mkEnableOption "keepassxc";
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
        #NOTE: already includes cli
        home.packages = with pkgs; [
          keepassxc
        ];
      }
    #nixos
    else
      {
        environment.persistence."/state".users.${userName} = {
          files = [
            {
              file = ".config/keepassxc/keepassxc.ini";
              method = "symlink";
            }
            {
              file = ".cache/keepassxc/keepassxc.ini";
              method = "symlink";
            }
          ];
        };
      };
}
