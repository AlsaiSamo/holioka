{pkgs, lib, ...}:

{
    home.packages = with pkgs; [
        libsecret
        keepassxc
    ];
    home.persistence."/state/home/imikoy" = {
        files = [
            ".config/keepassxc/keepassxc.ini"
            ".cache/keepassxc/keepassxc.ini"
        ];
    };
}
