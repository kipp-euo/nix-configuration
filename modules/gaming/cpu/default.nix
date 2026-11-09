{ ... }:
{
  boot.kernelModules = [ "ntsync" ];
  services.scx-loader = {
    enable = true;
    config.default_sched = "scx_lavd";
  };
}
