{
  config,
  lib,
  pkgs,
  flake_inputs,
  userName,
  ...
} @ inputs: let
  cfg = config.hlk.wine;
in {
  options.hlk.wine.enable = lib.mkEnableOption "wine";
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      wineWowPackages.stable
    ];
  };
}
