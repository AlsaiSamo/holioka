{
  config,
  lib,
  pkgs,
  flake_inputs,
  userName,
  ...
} @ inputs: let
  cfg = config.hlk.krita;
in {
  #TODO make Krita work with shortcuts
  options.hlk.krita.enable = lib.mkEnableOption "krita";
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      krita
    ];
    home.persistence."/state/home/${userName}" = {
      directories = [
        ".local/share/krita"
      ];
    };
  };
}
