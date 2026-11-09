{ ... }:
{
  boot.loader = {
    systemd-boot.enable = true;
    systemd-boot.consoleMode = "max";
    efi.canTouchEfiVariables = true;
  };
  boot.tmp.cleanOnBoot = true;
}
