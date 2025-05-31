select_user: {
  config,
  lib,
  pkgs,
  userName,
  ...
}: let
  cfg = config._hlk_auto.common;
  options._hlk_auto.common = {
    enable = lib.mkEnableOption "commonly used things";
  };
in {
  inherit options;
  config =
    if select_user
    #hm
    then
      lib.mkIf cfg.enable {
        home.packages = with pkgs; [
          blueberry
          cmus

          ffmpeg-full
          yt-dlp
          imagemagick

          alejandra
        ];

        home.persistence."/state/home/${userName}" = {
          allowOther = true;
          directories = [
            "Desktop"
            "Documents"
            #"Downloads"
            "Music"
            "Pictures"
            "Projects"
            "litter"

            #TODO: create audio module, move nixos/audio.nix stuff to it and add persisting this file in
            ".local/state/wireplumber"
            ".config/cmus"
          ];
        };
      }
    #nixos
    else {
    };
}
