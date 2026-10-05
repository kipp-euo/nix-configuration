{ ... }:
{
  imports = [
    ../common
    ./hardware-configuration.nix

    ../../modules/system/nvidia
    ../../modules/system/vm
    ../../modules/system/btrfs/hdd.nix
  ];
}
