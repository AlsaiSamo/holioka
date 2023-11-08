{ flake_inputs, flake_outputs, pkgs, config, lib, osConfig, ... }@inputs: {
  imports = [ (flake_inputs.impermanence + "/home-manager.nix") ]
    ++ [ ../modules/home-manager/default.nix ];
  programs.home-manager.enable = true;
  home.persistence."/state/home/imikoy" = {
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
