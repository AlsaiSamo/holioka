select_user: {
  config,
  lib,
  pkgs,
  userName,
  ...
}:
#Emacs config
#TODO: review the modules and later the entire config
let
  cfg = config._hlk_auto.emacs;
  options._hlk_auto.emacs = {
    default.enable = lib.mkEnableOption "default Doom Emacs configuration";
    package = lib.mkOption {
      description = "What Emacs to use as the base. Use emacs_FD for Xorg and emacsPGTK_fd for Wayland.";
      type = lib.types.package;
      default =
        if (config._hlk_auto.graphical.windowSystem == "xorg")
        then pkgs.emacs_FD
        else pkgs.emacsPGTK_FD;
    };
  };
in {
  inherit options;
  config =
    if select_user
    #hm
    then
      lib.mkIf cfg.default.enable {
        home.packages = with pkgs;
          [
            #LSP
            nil
          ]
          ++ (
            if (config._hlk_auto.graphical.windowSystem == "xorg")
            then [
              #TODO: check if any of these packages are needed on xorg or wayland and remove if possible
              xorg.xwininfo
              xclip
              xorg.xprop
              xdotool
            ]
            else []
          );
        services.emacs.enable = true;
        programs.doom-emacs = {
          enable = true;
          emacs = cfg.package;
          doomDir = ../../dotfiles/doom.d;
          #NOTE: I can use extraPackages to add packages to Emacs
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
      }
    #nixos
    else {};
}
