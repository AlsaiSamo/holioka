{
  config,
  lib,
  pkgs,
  flake_inputs,
  userName,
  ...
} @ inputs: let
  cfg = config.hlk.vmTools;
in {
  options.hlk.vmTools.enable = lib.mkEnableOption "various tools for virtual machines";
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      input-leap
    ];
    home.persistence."/state/home/${userName}" = {
      directories = [
        ".local/share/InputLeap"
        ".config/InputLeap"
      ];
    };
  };
}
