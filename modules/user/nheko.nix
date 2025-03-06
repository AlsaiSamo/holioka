select_user: {
  config,
  lib,
  pkgs,
  userName,
  ...
}:
#nheko matrix client
let
  cfg = config._hlk_auto.nheko;
  options._hlk_auto.nheko = {
    enable = lib.mkEnableOption "nheko matrix client";
  };
in {
  inherit options;
  config =
    if select_user
    #hm
    then lib.mkIf cfg.enable {
    #broken deprecated mess
        nixpkgs.config.permittedInsecurePackages = [
          "olm-3.2.16"
        ];
        programs.nheko.enable = true;
        home.persistence."/state/home/${userName}" = {
            allowOther = true;
            directories = [
            ".cache/nheko"
            ".config/nheko"
            ".local/share/nheko"
            ];
        };
    }
    #nixos
    else {};
}
