{
  inputs = {
    nixpkgs.url = "github:nixOS/nixpkgs/nixos-unstable";
    impermanence.url = "github:nix-community/impermanence";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    #firefox addons
    nur.url = "github:nix-community/NUR";
  };

  outputs = { self, nixpkgs, impermanence, home-manager, nur }:
    let
      mkSystem = {
        #class - East, West, South...
        #East - laptop for anything except heavy workloads
        #West - a PC for virtualising, rendering, hosting, etc.
        #South - router
        #North - smartphone
        #TODO create names for NAS, somene else's PC
        class,
        #Whether the machine can be carried
        carriable ? false,
        #Available graphics chips, and some information about them, which will be useful for vfio
        #Defines the PCI address and card's driver
        #{address = ""; driver = "";}
        graphics ? [ ],
        #empty = headless, display definitions include thei resolution and position center is [0 0]
        #{name = ""; position = [x y];}
        displays ? [ ],
        #extras - IOMMU, trackpoint, etc.
        extraCapabilities ? [ ],

        system,
        #Empty means "no user". Defines user's name, what state is backed up, etc.
        #TODO redo the state structure so that it will be like nix store, not like ~
        #TODO determine what defines a user
        users ? [ ] }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            #all systems are opt-in state
            impermanence.nixosModule
            (./hosts + ("/" + class + ".nix"))
            (./hosts + ("/" + class + "_hardware.nix"))
          ] ++ ((if (users != [ ]) then [
            home-manager.nixosModules.home-manager
            {
              home-manager.verbose = true;
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
            }
          ] else
            [ ]) ++ {
              nixpkgs.overlays = [

              ] ++ (if (users != [ ]) then [ nur.overlay ] else [ ]);
            });
          specialArgs = {
            #hm.im = impermanence.nixosModules.home-manager.impermanence;
          } // (if (users != [ ]) then {
            hm.im = impermanence.nixosModules.home-manager.impermanence;
          } else
            { });
        };
    in {
      nixosConfigurations = {
        west = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/west.nix
            impermanence.nixosModule
            home-manager.nixosModules.home-manager
            {
              home-manager.verbose = true;
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
            }
            { nixpkgs.overlays = [ nur.overlay ]; }
          ];
          specialArgs = {
            hm_im = impermanence.nixosModules.home-manager.impermanence;
          };
        };

        east = mkSystem {
          class = east;
          carriable = true;
          graphics = [{
            address = "00:01.0";
            driver = "AMD";
          }];
          #an external monitor is expected to be on the left side
          #dunno where the displayport goes
          displays = [
            {
              name = "eDP";
              position = [ 0 0 ];
            }
            {
              name = "HDMI-A-0";
              position = [ (-1) 0 ];
            }
          ];
          extraCapabilities = [ "trackpoint" "trackpad" ];
          system = "x86_64-linux";
          users = ["imikoy"];
        };

        east_before = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/east_before.nix
            impermanence.nixosModule
            home-manager.nixosModules.home-manager
            {
              home-manager.verbose = true;
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
            }
            { nixpkgs.overlays = [ nur.overlay ]; }
          ];
          specialArgs = {
            hm_im = impermanence.nixosModules.home-manager.impermanence;
          };
        };
      };

      overlays = { };
    };
}
