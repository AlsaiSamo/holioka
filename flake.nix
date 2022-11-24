{
	inputs = {
		nixpkgs.url = "github:nixOS/nixpkgs/nixos-unstable";
		impermanence.url = "github:nix-community/impermanence";
		home-manager.url = "github:nix-community/home-manager";
		home-manager.inputs.nixpkgs.follows = "nixpkgs";

#firefox addons
		nur.url = "github:nix-community/NUR";
	};

	outputs = {self
		, nixpkgs
		, impermanence
		, home-manager
		, nur
	}: {
		nixosConfigurations = {
			west = nixpkgs.lib.nixosSystem {
				system = "x86_64-linux";
				modules = [
					./hosts/west.nix
					impermanence.nixosModule
					home-manager.nixosModules.home-manager {
						home-manager.verbose = true;
						home-manager.useGlobalPkgs = true;
						home-manager.useUserPackages = true;
					}
					{nixpkgs.overlays = [
						nur.overlay
					];}
				];
				specialArgs = {
					hm_im = impermanence.nixosModules.home-manager.impermanence;
				};
			};
		};

		overlays = {
		};
	};
}
