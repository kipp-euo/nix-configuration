{ pkgs, ... }:
{
  programs.npm.enable = true;
  environment.systemPackages = with pkgs; [ 
    cargo
    clang
    gcc
    jdk
    python3
    python3Packages.pip
    python3Packages.virtualenv
    rustc
  ];
}
