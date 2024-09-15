{
  inputs = {
    nixpkgs.url = "github:nixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:nixOS/nixos-hardware";
    lix-mod = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.90.0.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur.url = "github:nix-community/NUR";
    ndeu = {
      url = "github:marienz/nix-doom-emacs-unstraightened";
      inputs.nixpkgs.follows = "";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixos-hardware,
    lix-mod,
    impermanence,
    home-manager,
    nur,
    ndeu,
    ...
  } @ flake_inputs: let
    #Secrets may be distributed together with state, but they are encrypted in the repo.
    secrets = import ./secrets.nix {};
    #Volatile configuration is different between physical machines and reinstalls
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
    allOverlays = [overlaysDefault nur.overlay];

    #These modules add options for all systems.
    commonNixosModules = [
      impermanence.nixosModule
      home-manager.nixosModules.home-manager
      nur.nixosModules.nur
      lix-mod.nixosModules.default
      (import ./modules)
    ];
    hmModules = [
      ndeu.hmModule
      impermanence.nixosModules.home-manager.impermanence
      nur.hmModules.nur
      ./modules/home-manager/default.nix
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
          ++ [
            (import ./machines/east)
            nixos-hardware.nixosModules.common-gpu-amd
            {
              nixpkgs.config.allowUnfree = true;
              nixpkgs.overlays = allOverlays;
            }
          ];
      };
      west = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit flake_inputs secrets volatile hmModules;
          inherit hmOverlay;
        };
        modules =
          commonNixosModules
          ++ [
            (import ./machines/west)
            nixos-hardware.nixosModules.lenovo-ideapad-15arh05
            {
              nixpkgs.config.allowUnfree = true;
              nixpkgs.overlays = allOverlays;
            }
          ];
      };
    };
  };
}
