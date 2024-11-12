inputs @ {
  lib,
  config,
  pkgs,
  secrets,
  extra,
  modulesPath,
  ...
}: {
  imports = [];
  hlk = {
    defaultFilesystems = true;
    stateRemoval.enable = false;
    backup.enable = true;
    network = {
      #TODO: rewrite network module because op6 seems to require a different
      #network managing solution
      default.enable = true;
      hostName = "north";
    };
    #TODO: a separate profile?
    mainUser = {
      #TODO: enable the user
      default.enable = false;
      extraUserConfig.hlk = {
        #TODO: enable only some things
        emacs.default.enable = false;
        games = {
          osu.state.enable = false;
          xonotic.state.enable = false;
        };
        krita.enable = false;
        vmTools.enable = false;
        graphical.windowSystem = "wayland";
        wine.enable = false;
      };
    };
  };
  #TODO: deal with hardware first
  system.stateVersion = "24.11";
}
