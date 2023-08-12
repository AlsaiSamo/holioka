{ config, lib, pkgs, flake_inputs, ...}@inputs:
{
    imports = [flake_inputs.nix-doom-emacs.hmModule];
    programs.doom-emacs = {
        enable = true;
        doomPrivateDir = ../../dotfiles/doom.d;
    };
    home.persistence."/state/home/imikoy/" = {
        allowOther = false;
        directories = [
        ".cache/doom"
        "org"
        ];
    };
}
