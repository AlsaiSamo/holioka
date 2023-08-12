{ lib, config, pkgs, ... }@inputs: {
  programs.gpg = {
    enable = true;
    homedir = "/state/secrets/.gnupg";
    #may break gnupg (scary)
    settings = {
      #TODO
    };
  };
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    enableZshIntegration = true;
    defaultCacheTtlSsh = 300;
    sshKeys = [ "50AF8896441CF20361687883C53B1A8D9D0FB49E" ];
    verbose = true;
    #TODO may break gpg
    extraConfig = ''
      allow-emacs-pinentry
      allow-loopback-pinentry
    '';
  };
}
