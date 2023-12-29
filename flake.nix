{
  inputs = {
    nixpkgs.url = "github:nixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:nixOS/nixos-hardware";
    impermanence.url = "github:nix-community/impermanence";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur.url = "github:nix-community/NUR";
    nix-doom-emacs = {url = "github:nix-community/nix-doom-emacs";};
  };

  outputs = {
    self,
    nixpkgs,
    nixos-hardware,
    impermanence,
    home-manager,
    nur,
    nix-doom-emacs,
    ...
  } @ flake_inputs: let
    #Secrets may be distributed together with state, but they are encrypted in the repo.
    secrets = import ./secrets.nix {};
    volatile = import ./volatile.nix {};
    #These modules add options for all systems.
    commonNixosModules = [
      impermanence.nixosModule
      home-manager.nixosModules.home-manager
      (import ./modules)
    ];
    hmModules = [
      nix-doom-emacs.hmModule
      impermanence.nixosModules.home-manager.impermanence
    ];
    #TODO: overlays (when I need them)
  in {
    nixosConfigurations = {
      east = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit flake_inputs secrets volatile hmModules;
        };
        modules =
          commonNixosModules
          ++ [(import ./machines/east)]
          ++ [
            nixos-hardware.nixosModules.common-gpu-amd
            {nixpkgs.overlays = [nur.overlay];}
          ];
      };
      west = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit flake_inputs secrets volatile hmModules;
        };
        modules =
          commonNixosModules
          ++ [(import ./machines/west)]
          ++ [
            nixos-hardware.nixosModules.lenovo-ideapad-15arh05
            {nixpkgs.overlays = [nur.overlay];}
            {nixpkgs.config.allowUnfree = true;}
          ];
      };
    };
  };
}
