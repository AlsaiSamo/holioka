{ config, lib, pkgs, ... }@ inputs: let
  cfg = config.hlk.barrier;
in
{
  options.hlk.barrier = {
    enable = lib.mkEnableOption "barrier - software KVM switch";
    #TODO: option to give a config
  };
  config = lib.mkIf cfg.enable {
    #TODO: not in PATH?
    environment.systemPackages = [pkgs.barrier];
    # systemd.services."barrier-server" = {
    # #TODO: systemd service for the server
    # };
  };
}
