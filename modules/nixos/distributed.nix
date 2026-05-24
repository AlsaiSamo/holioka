{
  config,
  lib,
  pkgs,
  secrets,
  ...
}@inputs:
let
  cfg = config.hlk.nix.distributed;
in
#NOTE: currently unused.
{
  options = {
    hlk.nix.distributed.enable = lib.mkEnableOption "remote building and store serving";
  };
  config = lib.mkIf cfg.enable {
    nix.distributedBuilds = true;
    nix.buildMachines = [
      secrets.west.asBuilder
    ];
  };
}
