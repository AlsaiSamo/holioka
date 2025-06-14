{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:nixOS/nixos-hardware";
    lix-mod = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.93.0.tar.gz";
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
      #NOTE: settings nixpkgs to "" is mentioned in the flake's repo
      inputs.nixpkgs.follows = "";
    };
    # TODO: actually use this
    niri = {
      url = "github:sodiboo/niri-flake";
    };
    mobile-nixos = {
      url = "github:mobile-nixos/mobile-nixos";
      flake = false;
    };
    # TODO: actually use this
    nix-colors.url = "github:Misterio77/nix-colors";
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
    niri,
    mobile-nixos,
    nix-colors,
    ...
  } @ flake_inputs: let
    #TODO: Usermodules: compare them against nixos modules, some settings  might have been duplicated
    #TODO: LIST OF WANTS
    #1. playerctl
    #1. RSS
    #2. Switch to nix-colors
    #3. Try out cutiepro colorscheme
    #4. nixos on the phone
    #5. full switch to wayland
    #Secrets may be distributed together with state, but they are encrypted in the repo.
    secrets = import ./secrets.nix {};
    #Volatile configuration is different between physical machines and reinstalls
    volatile = import ./volatile.nix {};

    overlays = args:
      import ./overlays ({
          lib = nixpkgs.lib;
          inherit flake_inputs;
        }
        // args);
    overlaysDefault = overlays {};
    hmOverlay = overlaysDefault;
    allOverlays =
      overlaysDefault
      ++ [
        nur.overlay
        niri.overlays.niri
        (import "${mobile-nixos}/overlay/overlay.nix")
      ];

    #These modules add options for all systems.
    nixosModules' = [
      impermanence.nixosModule
      nur.modules.nixos.default
      niri.nixosModules.niri
      home-manager.nixosModules.home-manager
      #NOTE: lix-mod.nixosModules.default is included on per-machine basis
      (import ./modules/nixos/default.nix)
    ];
    hmModules' = [
      impermanence.nixosModules.home-manager.impermanence
      nur.modules.homeManager.default
      ndeu.hmModule
      # niri.homeModules.niri
      nix-colors.homeManagerModules.default
    ];
    #pseudo-modules that affect both hm and nixos and so have identical option trees
    userModulesSystem = import ./modules/user/default.nix false;
    userModulesUser = import ./modules/user/default.nix true;

    nixosModules = nixosModules' ++ userModulesSystem;
    hmModules = hmModules' ++ userModulesUser;

    nixpkgsARM = import nixpkgs {
      overlays = allOverlays;
      crossSystem.system = "aarch64-linux";
      #TODO remove assumption of x86 system
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
      kernel = nixpkgsARM.linux_enchilada;
    };

    nixosConfigurations = {
      east = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit flake_inputs secrets volatile hmModules hmOverlay;
        };
        modules =
          nixosModules
          ++ [
            (import ./machines/east)
            (import ./hardware/thinkpad_a275)
            lix-mod.nixosModules.default
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
          inherit flake_inputs secrets volatile hmModules hmOverlay;
        };
        modules =
          nixosModules
          ++ [
            (import ./machines/west)
            (import ./hardware/ig3_15arh05)
            lix-mod.nixosModules.default
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
          inherit flake_inputs secrets volatile hmModules hmOverlay;
          pkgsARM = nixpkgsARM.pkgs;
          mobile = mobile-nixos;
        };
        modules =
          nixosModules
          ++ [
            (import ./machines/north)
            (import ./hardware/enchilada)
            #TODO: try to build on the phone
            lix-mod.nixosModules.default
            {
              nixpkgs.config.allowUnfree = true;
              nixpkgs.overlays = allOverlays;
            }
          ];
      };
      north_minimal = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = {
          inherit flake_inputs secrets volatile hmModules hmOverlay;
          pkgsARM = nixpkgsARM.pkgs;
          mobile = mobile-nixos;
        };
        modules =
          nixosModules
          ++ [
            (import ./machines/north/minimal.nix)
            (import ./hardware/enchilada)
            #TODO: try to build on the phone
            lix-mod.nixosModules.default
            {
              nixpkgs.config.allowUnfree = true;
              nixpkgs.overlays = allOverlays;
            }
          ];
      };
      #TODO: vm for north
    };
  };
}
