# A simple NixOS configuration with Hyprland
## Features
- Btrfs
- Hyprland and waybar
- Neovim as primary text editor and IDE
- Grimslurp + swappy for screenshots and quick editing
- Chinese cache substituters
- DoH (DNS over HTTPS) with dnscrypt-proxy
- [Zapret](https://github.com/kartavkun/zapret-discord-youtube)
## Installation (WIP)
- Change `username` and `host` in `variables.nix`
- Run `./install.sh`
## Notes
- Gamescope module is not enabled by default.
  - It breaks fonts, clipboard and locale in certain games. 
  - Gamescope forces the aspect ratio. Some games work just fine at arbitrary aspect ratios and can be used in tiling comfortably (in borderless/windowed mode).
  - I prefer using ingame upscaling and frame capping.
  - It solves problems that I don't have and introduces problems that I wouldn't have.
## Commands
### `Nix-rebuild`
Rebuilds current configuration, restarts hyprland and waybar service
### `Nix-update`
Backs up the current flake, updates flake and runs `Nix-rebuild`
