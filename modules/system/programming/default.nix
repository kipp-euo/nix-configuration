{ pkgs, ... }:
{
  programs.npm.enable = true;
  environment.systemPackages = with pkgs; [ 
    clang
    gcc
    jdk
    python3
    python3Packages.pip
    python3Packages.virtualenv
  ];
}
