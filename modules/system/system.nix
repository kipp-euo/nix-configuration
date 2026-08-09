{ pkgs, ... }:
{
	imports = [
		# ./gamescope
		./appimage-run
		./audio
		./bluetooth
		./bootloader/systemd-boot
		./btrfs
		./firewall
		./flatpak
		./fonts
		./gamemode
		# ./zapret
		./qbtorrent
		./git
		./gpuScreenRecorder
		./hypr
		./kernel
		./nix
		./ntfs
		./nvidia
		./sober
		./steam
		./users
		./swap
		./locale
		./thunar
		./timezone
	];
	nixpkgs.config.allowUnfree = true;
	environment.systemPackages = with pkgs; [
		curl
		gcc
		man-db
		neovim
		wget
	];
}
