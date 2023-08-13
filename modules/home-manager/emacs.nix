{ config, lib, pkgs, flake_inputs, ...}@inputs:
{
    imports = [flake_inputs.nix-doom-emacs.hmModule];
    programs.doom-emacs = {
        enable = true;
        doomPrivateDir = ../../dotfiles/doom.d;
    };
    #This does not allow GPG_TTY to be set. It is better to start Emcas from the login
    #shell.
    #services.emacs.enable = true;
    #TODO: make an Emacs systemd unit myself
    programs.zsh.loginExtra = ''
    emacs --daemon
    '';
    home.persistence."/state/home/imikoy/" = {
        allowOther = false;
        directories = [
        ".cache/doom"
        "org"
        ];
    };
    home.packages = [
        (pkgs.writeScriptBin "emacs-everywhere"
        ''
        emacsclient --eval "(emacs-everywhere)"
        '')
    ];
}
