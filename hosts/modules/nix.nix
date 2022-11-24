{ config, pkgs, ...}:

{
  nix = {
    package = pkgs.nixVersions.stable;
    settings = {
     # cores = 3;
      auto-optimise-store = true;
      trusted-users = ["root" "imikoy"];
    };
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true
      keep-derivations = true
    '';
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    optimise = {
      automatic = true;
      dates = ["weekly"];
    };
  };
  
  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };
}
