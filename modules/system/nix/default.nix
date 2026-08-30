{ pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      warn-dirty = false;
    };
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 7d";
    };
  };
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      
    ];
  };
}
