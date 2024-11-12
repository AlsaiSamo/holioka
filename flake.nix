{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
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
      #NOTE: mentioned in the repo
      inputs.nixpkgs.follows = "";
    };
    mobile-nixos = {
      url = "github:mobile-nixos/mobile-nixos";
      flake = false;
    };
  };

  outputs = {
    self,
    flake-utils,
    nixpkgs,
    nixos-hardware,
    lix-mod,
    impermanence,
    home-manager,
    nur,
    ndeu,
    mobile-nixos,
    ...
  } @ flake_inputs: let
    #Secrets may be distributed together with state, but they are encrypted in the repo.
    secrets = import ./secrets.nix {};
    #Volatile configuration is different between physical machines and reinstalls
    volatile = import ./volatile.nix {};

    #all overlays together
    #TODO: overlays {} should return a list of overlays
    # overlays = args: final: prev:
    #   import ./overlays/old.nix ({
    #       pkgsPrev = prev;
    #       pkgsFinal = final;
    #       lib = nixpkgs.lib;
    #       inherit flake_inputs;
    #     }
    #     // args);
    overlays = args:
      import ./overlays ({
          lib = nixpkgs.lib;
          inherit flake_inputs;
        }
        // args);
    overlaysDefault = overlays {};
    allOverlays = overlaysDefault ++ [nur.overlay];

    #These modules add options for all systems.
    commonNixosModules = [
      impermanence.nixosModule
      home-manager.nixosModules.home-manager
      nur.nixosModules.nur
      #NOTE: builds too long
      lix-mod.nixosModules.default
      (import ./modules/nixos/default.nix)
    ];
    hmModules = [
      ndeu.hmModule
      impermanence.nixosModules.home-manager.impermanence
      nur.hmModules.nur
      ./modules/home-manager/default.nix
    ];
    hmOverlay = overlaysDefault;

    nixpkgsARM = import nixpkgs {
      overlays = allOverlays;
      crossSystem.system = "aarch64-linux";
      #TODO make automatic
      localSystem.system = "x86_64-linux";
    };
    nixpkgsNoCross = import nixpkgs {
      overlays = allOverlays;
      localSystem.system = "aarch64-linux";
      config.allowUnfree = true;
    };
  in rec {
    packages."aarch64-linux" = {
      ubootImage = nixpkgsNoCross.ubootImage_enchilada;
      uboot = nixpkgsNoCross.uboot_enchilada;
      installer = nixpkgsNoCross.installer_enchilada nixpkgsARM.linux_enchilada;
      installer_filesystems = nixpkgsNoCross.installer_filesystems nixpkgsARM.linux_enchilada;
    };
    nixosConfigurations = {
      #TODO: try having multiple home-manager profiles instead of only the main one
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
            (import ./modules/nixos/common.nix)
            (import ./hardware/thinkpad_a275)
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
            (import ./modules/nixos/common.nix)
            (import ./hardware/ig3_15arh05)
            nixos-hardware.nixosModules.lenovo-ideapad-15arh05
            {
              nixpkgs.config.allowUnfree = true;
              nixpkgs.overlays = allOverlays;
            }
          ];
      };
      north = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = {
          inherit flake_inputs secrets volatile hmModules;
          inherit hmOverlay;
          pkgsARM = nixpkgsARM.pkgs;
          mobile = mobile-nixos;
        };
        modules =
          commonNixosModules
          ++ [
            (import ./machines/north)
            (import ./modules/nixos/common.nix)
            (import ./hardware/enchilada)
            {
              nixpkgs.config.allowUnfree = true;
              nixpkgs.overlays = allOverlays;
            }
          ];
      };
    };
  };
}
