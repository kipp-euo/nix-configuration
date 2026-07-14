{ config, pkgs, ... }:
let
	gamescope-wrapped = pkgs.writeShellScriptBin "gamescope-wrapped" ''
		exec ${pkgs.gamescope}/bin/gamescope \
			--rt \
			--immediate-flips \
			-f \
			-w 1920 \
			-W 1920 \
			-h 1080 \
			-H 1080 \
			--force-grab-cursor \
			"$@"
	'';
in
{
	programs.gamescope = {
		enable = true;
		capSysNice = true;
		args = [
			"--rt"
			"--immediate-flips"
			"-f"
			"-w 1920"
			"-W 1920"
			"-h 1080"
			"-H 1080"
			"--force-grab-cursor"
		];
	};
	programs.steam = {
		enable = true;
		remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
		dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
		localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
		gamescopeSession.enable = true;
		extraPackages = with pkgs; [
			gamescope-wrapped
			gamescope
		];
	};
}
