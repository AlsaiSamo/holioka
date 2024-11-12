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
    package = lib.mkOption {
      description = "What Emacs to use as the base. Use emacs_FD for Xorg and emacsPGTK_fd for Wayland.";
      type = lib.types.package;
      default = pkgs.emacs_FD;
    };
  };
  config = lib.mkIf cfg.default.enable {
    home.packages = with pkgs; [
      xorg.xwininfo
      xclip
      xorg.xprop
      xdotool

      nil
    ];
    services.emacs.enable = true;
    programs.doom-emacs = {
      enable = true;
      emacs = cfg.package;
      doomDir = ../../dotfiles/doom.d;
      #TODO: I can use extraPackages to add packages to Emacs
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
