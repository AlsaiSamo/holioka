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

    #all overlays together
    #stolen from chayleaf
    overlays = args: final: prev:
      import ./overlays ({
          pkgsPrev = prev;
          pkgsFinal = final;
          lib = nixpkgs.lib;
          inherit flake_inputs;
        }
        // args);
    overlaysDefault = overlays {};

    #These modules add options for all systems.
    commonNixosModules = [
      impermanence.nixosModule
      home-manager.nixosModules.home-manager
      nur.nixosModules.nur
      (import ./modules)
    ];
    hmModules = [
      nix-doom-emacs.hmModule
      impermanence.nixosModules.home-manager.impermanence
      #This is actually nur.nixosModules.nur
      nur.hmModules.nur
    ];
    hmOverlay = overlaysDefault;
  in {
    nixosConfigurations = {
      east = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit flake_inputs secrets volatile hmModules;
          inherit hmOverlay;
        };
        modules =
          commonNixosModules
          ++ [(import ./machines/east)]
          ++ [
            nixos-hardware.nixosModules.common-gpu-amd
            {nixpkgs.overlays = [nur.overlay];}
            {nixpkgs.config.allowUnfree = true;}
          ];
      };
      west = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit flake_inputs secrets volatile hmModules;
          #TODO: make it nicer
          inherit hmOverlay;
        };
        modules =
          commonNixosModules
          ++ [(import ./machines/west)]
          ++ [
            nixos-hardware.nixosModules.lenovo-ideapad-15arh05
            #TODO: I have had "nur.overlay" here, if it is not really needed remove
            #this comment
            {nixpkgs.overlays = [overlaysDefault];}
            {nixpkgs.config.allowUnfree = true;}
          ];
      };
    };
  };
}
