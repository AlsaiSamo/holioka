{ config, lib, pkgs, ... }@ inputs: let
  cfg = config.hlk.input-leap;
in
{
  options.hlk.input-leap = {
    enable = lib.mkEnableOption "input-leap - software KVM switch";
    #TODO: option to give a config
  };
  config = lib.mkIf cfg.enable {
    #TODO: not in PATH?
    environment.systemPackages = [pkgs.input-leap];
    # systemd.services."input-leap-server" = {
    # #TODO: systemd service for the server
    # };
  };
}
