{ ... }:
{
  imports = [
    ../common
    ./hardware-configuration.nix

    ../../modules/system/core/vm
  ];
}
