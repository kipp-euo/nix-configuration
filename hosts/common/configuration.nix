{ config, pkgs, ... }:
{
	imports = [
		./hardware-configuration.nix

		../../modules/system/audio
		../../modules/system/bluetooth
		../../modules/system/bootloader/systemd-boot
		../../modules/system/flatpak
		../../modules/system/fonts
		../../modules/system/git
		../../modules/system/hypr
		../../modules/system/ly
		../../modules/system/nix
		../../modules/system/steam
		../../modules/system/thunar
		../../modules/system/vpn
	];
	environment.sessionVariables.NIXOS_OZONE_WL = "1";

	# Use latest kernel.
	boot.kernelPackages = pkgs.linuxPackages_zen;

	networking.hostName = "laptop"; # Define your hostname.

	# Enable networking
	networking.networkmanager.enable = true;

	time.timeZone = "Asia/Vladivostok";

	i18n.defaultLocale = "ru_RU.UTF-8";
	i18n.extraLocaleSettings = {
		LC_ADDRESS = "ru_RU.UTF-8";
		LC_IDENTIFICATION = "ru_RU.UTF-8";
		LC_MEASUREMENT = "ru_RU.UTF-8";
		LC_MONETARY = "ru_RU.UTF-8";
		LC_NAME = "ru_RU.UTF-8";
		LC_NUMERIC = "ru_RU.UTF-8";
		LC_PAPER = "ru_RU.UTF-8";
		LC_TELEPHONE = "ru_RU.UTF-8";
		LC_TIME = "ru_RU.UTF-8";
	};
	console.font = "cyr-sun16";

	# Configure keymap in X11
	services.xserver.xkb = {
		layout = "us,ru";
		options = "grp:alt_shift_toggle";
		variant = "";
	};

	# Define a user account. Don't forget to set a password with ‘passwd’.
	users.users."kipp" = {
		isNormalUser = true;
		description = "Kipp";
		extraGroups = [ "networkmanager" "wheel" ];
		packages = with pkgs; [];
	};

	# Allow unfree packages
	nixpkgs.config.allowUnfree = true;

	environment.systemPackages = with pkgs; [
		wget
		git
		curl
		neovim
		man-db
	];


	# Some programs need SUID wrappers, can be configured further or are
	# started in user sessions.
	# programs.mtr.enable = true;
	# programs.gnupg.agent = {
	#	 enable = true;
	#	 enableSSHSupport = true;
	# };

	# List services that you want to enable:

	# Enable the OpenSSH daemon.
	# services.openssh.enable = true;

	# Open ports in the firewall.
	# networking.firewall.allowedTCPPorts = [ ... ];
	# networking.firewall.allowedUDPPorts = [ ... ];
	# Or disable the firewall altogether.
	# networking.firewall.enable = false;

	# This value determines the NixOS release from which the default
	# settings for stateful data, like file locations and database versions
	# on your system were taken. It‘s perfectly fine and recommended to leave
	# this value at the release version of the first install of this system.
	# Before changing this value read the documentation for this option
	# (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
	system.stateVersion = "26.05"; # Did you read the comment?
}
