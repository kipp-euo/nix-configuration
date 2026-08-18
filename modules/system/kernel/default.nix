{ pkgs, ... }:
{
	# boot.kernelPackages = pkgs.linuxPackagesFor (pkgs.linuxKernel.kernels.linux_zen.override {
	# 	extraMakeFlags = [
	# 		"KCFLAGS=-march=native"
	# 	];
	# });
	boot.kernelPackages = pkgs.linuxPackages_zen;
}
