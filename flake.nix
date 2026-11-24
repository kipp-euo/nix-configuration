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
    qml-language-server = {
      url = "github:cushycush/qml-language-server";
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
      system = "x86_64-linux";
    in
    {
      nixosConfigurations = {
        ${vars.host} = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit system inputs vars colors; };
          modules = [
            ./hosts/${vars.host}/configuration.nix

            nix-flatpak.nixosModules.nix-flatpak
            home-manager.nixosModules.default
            {
              environment.systemPackages = [
                inputs.qml-language-server.packages.${system}.default
              ];
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
