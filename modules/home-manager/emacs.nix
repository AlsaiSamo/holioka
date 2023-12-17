{ config, lib, pkgs, flake_inputs, ... }@inputs:
let
  emacs-everywhere = pkgs.writeScriptBin "emacs-everywhere" ''
    emacsclient --eval "(emacs-everywhere)"
  '';
in {
  imports = [ flake_inputs.nix-doom-emacs.hmModule ];
  home.packages = with pkgs; [
    xorg.xwininfo
    xclip
    xorg.xprop
    xdotool
    emacs-everywhere
  ];
  programs.doom-emacs = {
    enable = true;
    doomPrivateDir = ../../dotfiles/doom.d;
  };
  #Emacs cannot itself inherit gpg and ssh agent information. pkgs.keychain
  #needs to be used, and gpg_tty has to be set some other way.
  # services.emacs = {
  #     enable = true;
  #     #nvim is configured as default editor in nixos,
  #     #I think emacs will overshadow that
  #     defaultEditor = true;
  # };
  #TODO: check whether this works
  programs.zsh.loginExtra = ''
    if ! [[ -o interactive ]]; then
       emacs --daemon
    fi
  '';
  home.persistence."/state/home/imikoy/" = {
    allowOther = true;
    directories = [
      #Losing cache only leads to annoyingly long several minutes of wait.
      #".cache/doom"
      "org"
      #History-like things
      ".local/share/doom"
    ];
  };
  home.persistence."/local_state/home/imikoy" = {
    allowOther = true;
    directories = [ ".cache/doom" ];
  };
}
