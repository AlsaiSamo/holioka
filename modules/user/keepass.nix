select_user: {
  config,
  lib,
  pkgs,
  userName,
  ...
}: let
  cfg = config._hlk_auto.keepass;
  options._hlk_auto.keepass = {
    enable = lib.mkEnableOption "keepassxc";
  };
in {
  inherit options;
  config =
    if select_user
    #hm
    then
      lib.mkIf cfg.enable {
        #NOTE: already includes cli
        home.packages = with pkgs; [
          keepassxc
        ];
        home.persistence."/state/home/${userName}" = {
          files = [
            ".config/keepassxc/keepassxc.ini"
            ".cache/keepassxc/keepassxc.ini"
          ];
        };
      }
    #nixos
    else {};
}
