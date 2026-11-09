{ ... }:
{
  imports = [
    ../common
    ./hardware-configuration.nix

    ../../modules/core/btrfs/hdd.nix
    ../../modules/core/nvidia
    ../../modules/extra/vm
    ../../modules/extra/ollama
    # ../../modules/extra/minecraft-server
  ];
}
