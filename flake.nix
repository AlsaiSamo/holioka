{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:nixOS/nixos-hardware";
    lix = {
      url = "https://git.lix.systems/lix-project/lix/archive/main.tar.gz";
      flake = false;
    };
    lix-mod = {
      # url = "https://git.lix.systems/lix-project/nixos-module/archive/2.93.0.tar.gz";
      url = "https://git.lix.systems/lix-project/nixos-module/archive/main.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.lix.follows = "lix";
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
    #TODO: use this for the oneplus
    # niri = {
    #   url = "github:sodiboo/niri-flake";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    mobile-nixos = {
      url = "github:mobile-nixos/mobile-nixos";
      flake = false;
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
      ...
    }@flake_inputs:
    let
      #TODO: LIST OF WANTS
      #1. Develop new West system
      #2. Secrets storage?
      #3. Fix bindmounts
      #      They should be done without FUSE, but they should also be owned by the main user.
      #4. zfs setup guide
      #5. Support multiple state datasets
      #6. Switch West to the new laptop
      #7. MPD-based player (that will be similar to cmus)
      #8. playerctl
      #9. RSS
      #10. usable nixos on the phone
      #11. For file syncing, either scripts based on rsync, or git-annex/syncthing
      #12. Understand ssh host keys
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
        impermanence.nixosModules.home-manager.impermanence
        nur.modules.homeManager.default
        ndeu.hmModule
        # niri.homeModules.niri
      ];
      #pseudo-modules that affect both hm and nixos and so have identical option trees
      userModulesSystem = import ./modules/user/default.nix false;
      userModulesUser = import ./modules/user/default.nix true;

      nixosModules = nixosModules' ++ userModulesSystem;
      hmModules = hmModules' ++ userModulesUser;

      #Nixpkgs for cross-compiling the kernel
      nixpkgsARM = import nixpkgs {
        overlays = allOverlays;
        crossSystem.system = "aarch64-linux";
        #NOTE: assumes x86_64 builder
        localSystem.system = "x86_64-linux";
      };
      nixpkgsNoCross = import nixpkgs {
        overlays = allOverlays;
        localSystem.system = "aarch64-linux";
        config.allowUnfree = true;
      };
    in
    {
      #Packages for oneplus
      packages."aarch64-linux" = {
        ubootImage = nixpkgsNoCross.ubootImage_enchilada;
        uboot = nixpkgsNoCross.uboot_enchilada;
        buffyboard = nixpkgsNoCross.buffyboard;
        kernel = nixpkgsARM.linux_enchilada;
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
            (import ./hardware/ig3_15arh05)
            lix-mod.nixosModules.default
            nixos-hardware.nixosModules.lenovo-ideapad-15arh05
            {
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
            pkgsARM = nixpkgsARM.pkgs;
            mobile = mobile-nixos;
          };
          modules = nixosModules ++ [
            (import ./machines/north)
            (import ./hardware/enchilada)
            #TODO: try to build on the phone
            # lix-mod.nixosModules.default
            {
              nixpkgs.config.allowUnfree = true;
              nixpkgs.overlays = allOverlays;
            }
          ];
        };
        #Oneplus 6 (minified config to be used for first installation)
        #WARN: not tested
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
            pkgsARM = nixpkgsARM.pkgs;
            mobile = mobile-nixos;
          };
          modules = nixosModules ++ [
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
        #TODO: aarch64 vm for intalling on north
      };
    };
}
