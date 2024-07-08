{
  lib,
  config,
  pkgs,
  ...
} @ inputs: let
  cfg = config.hlk.avahi;
in {
  options.hlk.avahi.default.enable = lib.mkEnableOption "default Avahi config";
  config = {
    services.avahi = lib.mkIf cfg.default.enable {
      enable = true;
      nssmdns = true;
      publish = {
        enable = true;
        userServices = true;
        workstation = true;
        addresses = true;
        #not sure what this does
        #domain = true;
      };
    };
  };
}
