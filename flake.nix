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
    nix-minecraft.url = "github:Infinidoge/nix-minecraft";
    zapret-discord-youtube.url = "github:kartavkun/zapret-discord-youtube";
  };
  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nix-flatpak,
      zapret-discord-youtube,
      ...
    }@inputs:
    let
      vars = import ./variables.nix;
    in
    {
      nixosConfigurations = {
        ${vars.host} = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs vars; };
          system = "x86_64-linux";
          modules = [
            ./hosts/${vars.host}/configuration.nix

            nix-flatpak.nixosModules.nix-flatpak
            home-manager.nixosModules.default
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = { inherit inputs vars; };
                users.${vars.username} = ./modules/home/home.nix;
              };
            }
          ];
        };
      };
    };
}
