{ config, pkgs, ... }:
{
	swapDevices = [{ 
		device = "/swap/swapfile"; 
		size = 4*1024; # Creates an 8GB swap file 
	}];
	zramSwap = {
		enable = true;
		algorithm = "zstd";
		memoryMax = 8589934592;
		memoryPercent = 25;
		priority = 100;
	};
	boot.kernel.sysctl = {
		"vm.swappiness" = 10;
	};
}
