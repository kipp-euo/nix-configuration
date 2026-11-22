{ ... }:
{
  fileSystems."/swap".options = [
    "compress=zstd:3"
    "space_cache=v2"
    "discard=async"
    "noatime"
  ];
  swapDevices = [{ 
    device = "/swap/swapfile"; 
    size = 4*1024;
  }];
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 25;
    priority = 100;
  };
  boot.kernel.sysctl = {
    "vm.swappiness" = 100;
    "vm.page-cluster" = 0;
    "vm.watermark_boost_factor" = 0;
    "vm.watermark_scale_factor" = 125;
  };
}
