{
  config,
  lib,
  pkgs,
  secrets,
  ...
}: let
  cfg = config.hlk.ccache;
in {
  options.hlk.ccache = {
    enable = lib.mkEnableOption "ccache";
    #TODO: make this also apply to the overlay
    # storage = lib.mkOption {
    #   description = "Where ccache storage is located. It is advised to place it in local state directory.";
    #   default = "/var/cache/ccache";
    # };
  };
  config = lib.mkIf cfg.enable {
    programs.ccache.enable = true;
    nix.settings.extra-sandbox-paths = ["/var/cache/ccache"];
    #NOTE: for persisting, use local_state
  };
}
