{
  # osConfig,
  flake_inputs,
  pkgs,
  config,
  lib,
  hmModules,
  userName,
  ...
} @ inputs: {
  #TODO: move to somewhere else to generalise?
  _module.args.userName = userName;
  #TODO: move modules/home-manager/default.nix to hmModules after rewriting all modules
  imports = hmModules ++ [../modules/home-manager/default.nix];
  programs.home-manager.enable = true;

  hlk = {
    cli.default.enable = true;
    emacs.default.enable = true;
    firefox.default.enable = true;
    games = {
      osu.state.enable = true;
      xonotic.state.enable = true;
      xonotic.enable = true;
    };
  };

  home.persistence."/state/home/${userName}" = {
    allowOther = true;
    directories = [
      #Never used it
      #"Scripts"
      "Desktop"
      "Documents"
      #Was persisted before, not now
      #"Downloads"
      "Music"
      "Pictures"
      "Projects"
    ];
  };

  home.stateVersion = "23.11";
}
