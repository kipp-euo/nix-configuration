{
	description = "Flake.";
	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
		home-manager = {
			url = "github:nix-community/home-manager";
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};
	outputs = { self, nixpkgs, home-manager, ... }@inputs: {
		nixosConfigurations = {
			laptop = nixpkgs.lib.nixosSystem {
				system = "x86_64-linux";
				modules = [
					./hosts/common/configuration.nix

					home-manager.nixosModules.default
					{
						home-manager = {
							useGlobalPkgs = true;
							useUserPackages = true;
							users.kipp = ./modules/home/home.nix;
						};
					}
				];
			};
		};
	};
}
