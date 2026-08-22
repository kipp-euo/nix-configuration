{ ... }:
{
  imports = [
    ../common
    ./hardware-configuration.nix

    ../../modules/system/nvidia
  ];
}
