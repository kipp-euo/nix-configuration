{ ... }:
{
  imports = [
    ../common
    ./hardware-configuration.nix

    ../../modules/system/vm
  ];
}
