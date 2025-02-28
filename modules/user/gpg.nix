select_user: {
  config,
  lib,
  pkgs,
  secrets,
  ...
}:
# Example of a userModule, copy it and fill in
let
  cfg = config._hlk_auto.gpg;
  options._hlk_auto.gpg = {
    default.enable = lib.mkEnableOption "default GPG configuration";
  };
in {
  inherit options;
  config =
    if select_user
    #hm
    then
      lib.mkIf cfg.default.enable {
        programs.gpg = {
          enable = true;
          homedir = "/state/secrets/.gnupg";
          mutableKeys = true;
          mutableTrust = true;
          settings = {};
        };
        services.gpg-agent = {
          enable = true;
          enableSshSupport = true;
          enableZshIntegration = true;
          defaultCacheTtlSsh = 300;
          pinentryPackage = pkgs.pinentry-qt;
          sshKeys = [secrets.common.gpgAgentSshKey];
          verbose = true;
          enableExtraSocket = true;
        };
      }
    #nixos
    else {};
}
