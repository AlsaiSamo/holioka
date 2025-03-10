select_user: {
  config,
  lib,
  pkgs,
  userName,
  ...
}: let
  cfg = config._hlk_auto.krita;
  options._hlk_auto.krita.enable = lib.mkEnableOption "krita";
in {
  inherit options;
  config =
    if select_user
    #hm
    then
      lib.mkIf cfg.enable {
        home.packages = with pkgs; [
          krita
        ];
        #TODO: startup script for krita:
        #1. exclude krita from the list of prorgams accessible through gui runner
        #2. make a script that copies the files for krita to use
        #3. add script to the list of programs accessible through gui runner
        home.persistence."/state/home/${userName}" = {
          files = [
            ".config/kritarc"
            ".config/kritashortcutrc"
            ".config/kritashortcutsrc"
          ];
          directories = [
            ".local/share/krita"
          ];
        };
      }
    #nixos
    else {};
}
