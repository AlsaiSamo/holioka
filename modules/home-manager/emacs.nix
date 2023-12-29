{
  config,
  lib,
  pkgs,
  flake_inputs,
  userName,
  ...
} @ inputs: let
  cfg = config.hlk.emacs;
in {
  options.hlk.emacs = {
    default.enable = lib.mkEnableOption "default Doom Emacs configuration";
  };
  config = lib.mkIf cfg.default.enable {
    home.packages = with pkgs; [
      xorg.xwininfo
      xclip
      xorg.xprop
      xdotool
    ];
    programs.doom-emacs = {
      enable = true;
      #TODO: NDE issue
      emacsPackage = pkgs.emacs28;
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
    #This does not work either, oh well
    programs.zsh.loginExtra = ''
      if ! [[ -o interactive ]]; then
         emacs --daemon
      fi
    '';
    home.persistence."/state/home/${userName}/" = {
      allowOther = true;
      directories = [
        #Losing cache only leads to annoyingly long several minutes of wait.
        #".cache/doom"
        "org"
        #History-like things
        ".local/share/doom"
      ];
    };
    home.persistence."/local_state/home/${userName}" = {
      allowOther = true;
      directories = [".cache/doom"];
    };
  };
}
