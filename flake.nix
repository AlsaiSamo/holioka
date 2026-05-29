{
  inputs = {
    nixpkgs.url = "github:nixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:nixOS/nixos-hardware";
    lix = {
      url = "https://git.lix.systems/lix-project/lix/archive/main.tar.gz";
      flake = false;
    };
    lix-mod = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/main.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.lix.follows = "lix";
    };
    impermanence.url = "github:nix-community/impermanence";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    #used for firefox addons
    nur.url = "github:nix-community/NUR";
    ndeu = {
      url = "github:marienz/nix-doom-emacs-unstraightened";
      #NOTE: settings nixpkgs to "" is mentioned in the flake's repo
      inputs.nixpkgs.follows = "";
    };
    #TODO: use this for North?
    # niri = {
    #   url = "github:sodiboo/niri-flake";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    mobile-nixos = {
      url = "github:mobile-nixos/mobile-nixos";
      flake = false;
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      flake-utils,
      nixpkgs,
      nixos-hardware,
      lix-mod,
      impermanence,
      home-manager,
      nur,
      ndeu,
      # niri,
      mobile-nixos,
      nixvim,
      ...
    }@flake_inputs:
    let

      #Secrets may be distributed together with state, but they are encrypted in the repo.
      secrets = import ./secrets.nix { };
      #Volatile configuration is different between physical machines and reinstalls
      volatile = import ./volatile.nix { };

      overlays =
        args:
        import ./overlays (
          {
            lib = nixpkgs.lib;
            inherit flake_inputs;
          }
          // args
        );
      overlaysDefault = overlays { };
      hmOverlay = overlaysDefault ++ [
        # niri.overlays.niri
      ];
      allOverlays = overlaysDefault ++ [
        nur.overlays.default
        # niri.overlays.niri
        (import "${mobile-nixos}/overlay/overlay.nix")
      ];

      #These modules add options for all systems.
      #NOTE: lix-mod.nixosModules.default is included on per-machine basis
      nixosModules' = [
        impermanence.nixosModule
        nur.modules.nixos.default
        # niri.nixosModules.niri
        home-manager.nixosModules.home-manager
        (import ./modules/nixos/default.nix)
      ];
      hmModules' = [
        nur.modules.homeManager.default
        ndeu.homeModule
        nixvim.homeModules.nixvim
        # niri.homeModules.niri
      ];
      #pseudo-modules that affect both hm and nixos and so have identical option trees
      userModulesSystem = import ./modules/user/default.nix false;
      userModulesUser = import ./modules/user/default.nix true;

      nixosModules = nixosModules' ++ userModulesSystem;
      hmModules = hmModules' ++ userModulesUser;

      #Nixpkgs for cross-compiling the kernel
      nixpkgsArmCross = import nixpkgs {
        overlays = allOverlays;
        crossSystem.system = "aarch64-linux";
        #NOTE: assumes x86_64 builder
        localSystem.system = "x86_64-linux";
      };
    in
    {
      #Packages for north
      packages."aarch64-linux" = {
        uboot = nixpkgsArmCross.uboot_spacewar;
        ubootImage = nixpkgsArmCross.ubootImage_spacewar;
        kernel = nixpkgsArmCross.linux_spacewar;
      };

      nixosConfigurations = {
        #Secondary system
        east = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit
              flake_inputs
              secrets
              volatile
              hmModules
              hmOverlay
              ;
          };
          modules = nixosModules ++ [
            (import ./machines/east)
            (import ./hardware/thinkpad_a275)
            lix-mod.nixosModules.default
            nixos-hardware.nixosModules.common-gpu-amd
            {
              imports = [ volatile.east ];
              nixpkgs.config.allowUnfree = true;
              nixpkgs.overlays = allOverlays;
            }
          ];
        };
        #Primary system
        west = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit
              flake_inputs
              secrets
              volatile
              hmModules
              hmOverlay
              ;
          };
          modules = nixosModules ++ [
            (import ./machines/west)
            (import ./hardware/thinkpad_e15_g4_amd)
            lix-mod.nixosModules.default
            {
              imports = [ volatile.west ];
              nixpkgs.config.allowUnfree = true;
              nixpkgs.overlays = allOverlays;
            }
          ];
        };
        #Oneplus 6
        north = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = {
            inherit
              flake_inputs
              secrets
              volatile
              hmModules
              hmOverlay
              ;
            pkgsARM = nixpkgsArmCross.pkgs;
            mobile = mobile-nixos;
          };
          modules = nixosModules ++ [
            (import ./machines/north)
            (import ./hardware/enchilada)
            #TODO: try to build on the phone
            # lix-mod.nixosModules.default
            {
              imports = [ volatile.north ];
              nixpkgs.config.allowUnfree = true;
              nixpkgs.overlays = allOverlays;
            }
          ];
        };
        # Minified config to be used for first installation
        # WARN: not tested
        north_minimal = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = {
            inherit
              flake_inputs
              secrets
              volatile
              hmModules
              hmOverlay
              ;
            pkgsARM = nixpkgsArmCross.pkgs;
            mobile = mobile-nixos;
          };
          modules = nixosModules ++ [
            (import ./machines/north/minimal.nix)
            (import ./hardware/enchilada)
            {
              imports = [ volatile.north ];
              nixpkgs.config.allowUnfree = true;
              nixpkgs.overlays = allOverlays;
            }
          ];
        };
        #TODO: aarch64 vm for installing on north
      };
    };
}
