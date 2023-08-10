{ flake_inputs, flake_outputs, pkgs, config, lib, osConfig, ... }@inputs: {
  imports = [ (flake_inputs.impermanence + "/home-manager.nix") ]
    ++ [ ../modules/home-manager/default.nix ];
  programs.home-manager.enable = true;
  home.persistence."/state/home/imikoy" = {
    allowOther = true;
    directories = [
      "Scripts"
      "Desktop"
      "Documents"
      "Downloads"
      "Music"
      "Pictures"
      "Projects"
    ];
  };

  home.stateVersion = "23.11";
}
