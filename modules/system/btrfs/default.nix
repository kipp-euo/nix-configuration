{ config, pkgs, ... }:
{
	fileSystems = {
		"/".options = [ "compress=zstd:3" "space_cache=v2" "discard=async" "noatime" ];
		"/home".options = [ "compress=zstd:3" "space_cache=v2" "discard=async" "noatime" ];
		"/nix".options = [ "compress=zstd:3" "space_cache=v2" "discard=async" "noatime" ];
		"/swap".options = [ "compress=zstd:3" "space_cache=v2" "discard=async" "noatime" ];
	};
	services.btrfs.autoScrub = {
		enable = true;
		interval = "weekly";
		fileSystems = [ "/" ];
	};

}
