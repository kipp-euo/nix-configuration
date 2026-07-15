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
			-- \
			"$@"
	'';
	gamescope-wrapped-steam = pkgs.writeShellScriptBin "gamescope-wrapped-steam" ''
		LD_PRELOAD="" exec ${pkgs.gamescope}/bin/gamescope \
			--rt \
			--immediate-flips \
			-f \
			-w 1920 \
			-W 1920 \
			-h 1080 \
			-H 1080 \
			--force-grab-cursor \
			-- \
			env LD_PRELOAD="''${LD_PRELOAD:-}" \
			"$@"
	'';
in
{
	environment.systemPackages = [
		gamescope-wrapped
		gamescope-wrapped-steam
	];
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
			gamescope
			gamescope-wrapped
			gamescope-wrapped-steam
		];
	};
}
