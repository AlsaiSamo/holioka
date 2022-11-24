{config, pkgs, ...}:
{
    programs.gpg = {
        enable = true;
        homedir = "/state/secrets/.gnupg";
        #settings
#TODO
    };
    services.gpg-agent = {
        enable = true;
        #enableExtraSocket = true;
        enableSshSupport = true;
        enableZshIntegration = true;
        defaultCacheTtlSsh = 300;
        sshKeys = ["50AF8896441CF20361687883C53B1A8D9D0FB49E"];
        verbose = true;
    };
}
