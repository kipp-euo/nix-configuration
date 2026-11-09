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
    nix-minecraft = {
      url = "github:Infinidoge/nix-minecraft";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zapret-discord-youtube = {
      url = "github:kartavkun/zapret-discord-youtube";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
      colors = import ./colors.nix;
    in
    {
      nixosConfigurations = {
        ${vars.host} = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs vars colors; };
          system = "x86_64-linux";
          modules = [
            ./hosts/${vars.host}/configuration.nix

            nix-flatpak.nixosModules.nix-flatpak
            home-manager.nixosModules.default
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = { inherit inputs vars colors; };
                users.${vars.username} = {
                  programs.home-manager.enable = true;
                  home.stateVersion = "26.05";
                };
              };
            }
          ];
        };
      };
    };
}
