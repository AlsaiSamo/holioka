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
    nix-doom-emacs = { url = "github:nix-community/nix-doom-emacs"; };
    nixd.url = "github:nix-community/nixd";
  };

  outputs = { self, nixpkgs, nixos-hardware, impermanence, home-manager, nur
    , nix-doom-emacs, nixd, ... }@inputs:
    let
      inherit (self) outputs;
      #Secrets may be distributed together with state, but they are encrypted in the repo.
      secrets = import ./secrets.nix { };
      commonNixosModules = [ impermanence.nixosModule ]
        ++ [ (import ./modules/nixos) ];
    in rec {
      #TODO: out-of-nixpkgs packages
      #TODO: make it be available for all systems
      packages =
        import ./packages { pkgs = nixpkgs.legacyPackages."x86_64-linux"; };
      #TODO: overlays
      #TODO: shell for bootstrapping
      nixosConfigurations = {
        east = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit secrets inputs outputs; };
          modules = commonNixosModules ++ [ (import ./machines/east) ] ++ [
            nixos-hardware.nixosModules.common-gpu-amd
            { nixpkgs.overlays = [ nur.overlay nixd.overlays.default ]; }
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useUserPackages = true;
                useGlobalPkgs = true;
                verbose = true;
                extraSpecialArgs = {
                  flake_inputs = inputs;
                  flake_outputs = outputs;
                  inherit secrets;
                };
              };
              home-manager.users.imikoy = import ./users/imikoyFull.nix;
            }
          ];
        };
        west = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit secrets inputs outputs; };
          modules = commonNixosModules ++ [ (import ./machines/west) ] ++ [
            nixos-hardware.nixosModules.lenovo-ideapad-15arh05
            { nixpkgs.overlays = [ nur.overlay nixd.overlays.default ]; }
            {nixpkgs.config.allowUnfree = true;}
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useUserPackages = true;
                useGlobalPkgs = true;
                verbose = true;
                extraSpecialArgs = {
                  flake_inputs = inputs;
                  flake_outputs = outputs;
                  inherit secrets;
                };
              };
              home-manager.users.imikoy = import ./users/imikoyFull.nix;
            }
          ];
        };
      };
    };
}

