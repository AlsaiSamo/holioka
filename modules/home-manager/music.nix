{
  config,
  lib,
  pkgs,
  ...
} @ inputs: let
  cfg = config.hlk.music;
in {
  options.hlk.music = {
    mpd = {
      #TODO: network stuff
      enable = lib.mkEnableOption "Music Player Daemon";
      musicDir = lib.mkOption {
        example = "$XDG_DATA_HOME/Music";
        description = "passthrough for `services.mpd.musicDirectory`";
        type = lib.types.either lib.types.str lib.types.path;
      };
      dataDir = lib.mkOption {
        description = "passthrough for `services.mpd.dataDir`";
        type = lib.types.path;
      };
    };
    ncmpcpp.enable = lib.mkEnableOption "ncmpcpp client";
    #TODO: other clients?
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.mpd.enable {
      services.mpd = lib.mkIf cfg.mpd.enable {
        enable = true;
        musicDirectory = cfg.mpd.musicDir;
        dataDir = cfg.mpd.dataDir;
        extraArgs = ["--verbose"];
        #TODO: have it use pulseaudio mixer
      };
    })
    (lib.mkIf cfg.ncmpcpp.enable {
      programs.ncmpcpp = {
        enable = true;
        #TODO: binds?
        #TODO:
        #settings
      };
    })
  ];
}
