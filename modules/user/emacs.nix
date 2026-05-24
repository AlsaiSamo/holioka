select_user:
{
  config,
  lib,
  pkgs,
  userName,
  ...
}:
#Emacs config
#TODO: for emacs-everywhere to know that it runs under Wayland, it checks WAYLAND_DISPLAY.
#Which is not set because it isn't in the environment of the daemon, since it is started by systemd.
#A restart of the daemon helps, ofc, but it is not a good solution.
#TODO: revise configuration
#TODO: revise packages
#TODO: revise keymaps
let
  cfg = config._hlk_auto.emacs;
  options._hlk_auto.emacs = {
    default.enable = lib.mkEnableOption "default Doom Emacs configuration - the primary IDE.";
    package = lib.mkOption {
      description = "What Emacs to use as the base.
        By default Emacs is compiled with increased open file descriptors limit.
        By default the option uses emacs_FD for Xorg and emacsPGTK_FD for Wayland.";
      type = lib.types.package;
      default =
        if (config._hlk_auto.graphical.desktopVariant == "xorg") then pkgs.emacs_FD else pkgs.emacsPGTK_FD;
    };
  };
in
{
  inherit options;
  config =
    if
      select_user
    #hm
    then
      lib.mkIf cfg.default.enable {
        home.packages =
          with pkgs;
          [
            #font
            aporetic
            #for dired
            vips
            imagemagick
            poppler
            gnutar
            unzip
            mediainfo
            ffmpegthumbnailer
            #for SPC-s-f
            findutils
            ripgrep
            #for irc
            gnutls
            #for langs
            lldb
            cmake
            nil
            clang-tools
            pandoc
            nixfmt
            rust-analyzer
            rustfmt
            # sbcl #I'm using it on per-project basis
            # lua-language-server
            # mdl
            # guile
            # bash-language-server
            # shellcheck
            # pyright
            # black
          ]
          ++ (
            if (config._hlk_auto.graphical.desktopVariant == "xorg") then
              [
                # for emacs-everywhere
                xorg.xwininfo
                xclip
                xorg.xprop
                xdotool
              ]
            else if (config._hlk_auto.graphical.desktopVariant == "wayland") then
              [
                # for emacs-everywhere
                wtype
                wl-clipboard
              ]
            else
              [ ]
          );
        services.emacs.enable = true;
        programs.doom-emacs = {
          enable = true;
          emacs = cfg.package;
          #fixes the package redownloads at every change in the flake, seemingly
          experimentalFetchTree = true;
          doomDir = ../../dotfiles/doom.d;
          extraPackages = epkgs: with epkgs; [ treesit-grammars.with-all-grammars ];
        };
      }
    #nixos
    else
      {
        environment.persistence."/state".users.${userName} = {
          directories = [
            #Losing cache only leads to annoyingly long several minutes of wait.
            #".cache/doom"
            "org"
            #History-like things
            ".local/share/doom"
          ];
        };
        environment.persistence."/local_state".users.${userName} = {
          directories = [ ".cache/doom" ];
        };
      };
}
