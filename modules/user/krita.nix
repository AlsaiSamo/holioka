select_user:
{
  config,
  lib,
  pkgs,
  userName,
  ...
}:
let
  cfg = config._hlk_auto.krita;
  options._hlk_auto.krita.enable = lib.mkEnableOption "krita";
in
{
  inherit options;
  config =
    if
      select_user
    #hm
    then
      lib.mkIf cfg.enable {
        home.packages = with pkgs; [
          krita
        ];
      }
    #nixos
    else
      {
        environment.persistence."/state".users.${userName} = {
          files = [
            {
              file = ".config/kritarc";
              method = "symlink";
            }
            {
              file = ".config/kritashortcutrc";
              method = "symlink";
            }
            {
              file = ".config/kritashortcutsrc";
              method = "symlink";
            }
          ];
          directories = [
            ".local/share/krita"
          ];
        };
      };
}
