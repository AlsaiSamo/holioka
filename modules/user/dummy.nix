select_user: {
  config,
  lib,
  pkgs,
  userName,
  ...
}:
# Example of a userModule, copy it and fill in
let
  cfg = config._hlk_auto;
  options._hlk_auto = {};
in {
  inherit options;
  config =
    if select_user
    #hm
    then {
    }
    #nixos
    else {};
}
