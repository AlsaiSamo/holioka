{
  lib,
  config,
  pkgs,
  ...
} @ inputs: let
  cfg = config.hlk.gpg;
in {
  options.hlk.gpg = {
    default.enable = lib.mkEnableOption "default GPG configuration";
  };
  config = lib.mkIf cfg.default.enable {
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
      sshKeys = ["50AF8896441CF20361687883C53B1A8D9D0FB49E"];
      verbose = true;
      #This does not work, GPG uses config from the state
      # extraConfig = ''
      #   allow-emacs-pinentry
      #   allow-loopback-pinentry
      # '';
      enableExtraSocket = true;
    };
  };
}
