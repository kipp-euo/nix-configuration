{ ... }:
{
  imports = [
    ../common
    ./hardware-configuration.nix

    ../../modules/system/nvidia
    ../../modules/system/btrfs/hdd.nix
    # ../../modules/system/ollama
    # ../../modules/system/minecraft-server
  ];
}
