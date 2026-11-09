{ ... }:
{
  imports = [
    ../common
    ./hardware-configuration.nix

    ../../modules/system/core/btrfs/hdd.nix
    ../../modules/system/core/nvidia
    ../../modules/system/extra/vm
    # ../../modules/system/extra/ollama
    # ../../modules/system/extra/minecraft-server
  ];
}
