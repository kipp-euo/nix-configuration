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
		memoryMax = 8589934592;
		memoryPercent = 25;
		priority = 100;
	};
	boot.kernel.sysctl = {
		"vm.swappiness" = 100;
	};
}
