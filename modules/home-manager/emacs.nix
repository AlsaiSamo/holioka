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
    services.emacs.enable = true;
    programs.doom-emacs = {
      enable = true;
      #TODO: NDE issue
      emacsPackage = pkgs.emacs28;
      doomPrivateDir = ../../dotfiles/doom.d;
    };
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
