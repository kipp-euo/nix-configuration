{ pkgs, ... }:
{
  # @WBVLess_bot
  programs.clash-verge = {
    enable = true;
    package = pkgs.clash-verge-rev;
    serviceMode = true;
    tunMode = true;
    autoStart = true;
    group = "users";
  };
}

