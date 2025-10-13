select_user:
{
  config,
  lib,
  pkgs,
  secrets,
  ...
}:
let
  cfg = config._hlk_auto.gpg;
  options._hlk_auto.gpg = {
    default.enable = lib.mkEnableOption "default GPG configuration";
  };
in
{
  inherit options;
  config =
    if
      select_user
    #hm
    then
      lib.mkIf cfg.default.enable {
        programs.gpg = {
          enable = true;
          homedir = "/state/secrets/.gnupg";
          mutableKeys = true;
          mutableTrust = true;
          settings = { };
        };
        services.gpg-agent = {
          enable = true;
          enableSshSupport = true;
          enableZshIntegration = true;
          defaultCacheTtlSsh = 300;
          pinentry.package = pkgs.pinentry-qt;
          sshKeys = [
            secrets.common.gpgAgentSshKey
            secrets.common.gpgAgentSshKeyED25519
          ];
          verbose = true;
          enableExtraSocket = true;
        };
      }
    #nixos
    else
      { };
}
