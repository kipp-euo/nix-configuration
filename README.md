# A simple NixOS configuration with Hyprland
## Features
- Btrfs
- Chinese cache substituters
- Hyprland and waybar
- Neovim (lazy.nvim wih plugin manager)
- [Zapret](https://github.com/kartavkun/zapret-discord-youtube)
## Notes
- Gamescope module is not enabled by default.
  - It causes problems with fonts, clipboard and locale in certain games. 
  - Gamescope forces the aspect ratio. But some games work just fine at arbitrary aspect ratios and can be used in tiling comfortably (in borderless/windowed mode).
  - I prefer using ingame upscaling and frame capping.
  - Overall, it solves problems that I don't have and introduces problems that I wouldn't have without it.
- Themes are light mode, everything is moslty plain #f7f7ff.
  - I like light mode.
  - I don't need anything fancy.

## Scripts
### `rebuild.sh`
Quickly rebuild current configuration, restart hyprland and waybar
### `update.sh`
Backup current flake, update and do `rebuild.sh`
