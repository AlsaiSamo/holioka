select_user:
{
  config,
  lib,
  pkgs,
  userName,
  ...
}:
let
  cfg = config._hlk_auto.common;
  options._hlk_auto.common = {
    enable = lib.mkEnableOption "commonly used things";
  };
in
{
  inherit options;
  config =
    if
      select_user
    #hm
    then
      lib.mkIf cfg.enable {
        #NOTE: playerctl may be useful for custom music menus
        home.packages = with pkgs; [
          blueman
          cmus

          ffmpeg-full
          yt-dlp
          imagemagick
        ];
      }
    #nixos
    else
      lib.mkIf cfg.enable {
        environment.persistence."/state".users.${userName} = {
          directories = [
            "Desktop"
            "Documents"
            "Pictures"
            "Pictures/screenshots"
            # These are taken from local state or state.
            # "Downloads"
            # "Music"
            # "Projects"
            # "litter"

            #TODO: move out
            ".local/state/wireplumber"
            ".config/cmus"
          ];
        };
        # impermanence won't work with music and projects, so they are added like this.
        # Downloads and litter are also added like this because it's easy to do.
        systemd.tmpfiles.rules = [
          "L+ /home/${userName}/Downloads -   -   -   -   /local_state/home/${userName}/Downloads"
        ]
        ++ (
          if config.hlk.musicDataset.enable then
            [
              "L+ /home/${userName}/Music -   -   -   -   /local_state/music"
            ]
          else
            [ ]
        )
        ++ (
          if config.hlk.projectsDataset.enable then
            [
              "L+ /home/${userName}/litter -   -   -   -   /local_state/home/${userName}/litter"
              "L+ /home/${userName}/Projects -   -   -   -   /state/projects"
            ]
          else
            [ ]
        );
      };
}
