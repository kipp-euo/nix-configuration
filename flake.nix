{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak = {
      url = "github:gmodena/nix-flatpak/?ref=latest";
    };
    zapret-discord-youtube.url = "github:kartavkun/zapret-discord-youtube";
    nix-minecraft.url = "github:Infinidoge/nix-minecraft";
  };
  outputs = {
    self,
    nixpkgs,
    home-manager,
    nix-flatpak,
    zapret-discord-youtube,
    ...
  } @ inputs:
  {
    nixosConfigurations = {
      laptop = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        system = "x86_64-linux";
        modules = [
          ./hosts/laptop/configuration.nix

          nix-flatpak.nixosModules.nix-flatpak
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
      pc = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        system = "x86_64-linux";
        modules = [
          ./hosts/pc/configuration.nix

          nix-flatpak.nixosModules.nix-flatpak
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
