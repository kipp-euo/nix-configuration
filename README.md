# A simple NixOS configuration with Hyprland
## Features
- Btrfs
- Hyprland and waybar
- Neovim as primary text editor and IDE
- Grimslurp + swappy for screenshots and quick editing
- Chinese cache substituters
- DoH (DNS over HTTPS) with dnscrypt-proxy
- [Zapret](https://github.com/kartavkun/zapret-discord-youtube)
## Notes
- Gamescope module is not enabled by default.
  - It breaks fonts, clipboard and locale in certain games. 
  - Gamescope forces the aspect ratio. But some games work just fine at arbitrary aspect ratios and can be used in tiling comfortably (in borderless/windowed mode).
  - I prefer using ingame upscaling and frame capping.
  - To sum up, it solves problems that I don't have and introduces problems that I wouldn't have without it.
- Themes are light mode, everything is moslty plain `#f7f7ff`.
  - I like light mode.
  - I don't need anything fancy.
## Scripts
### `rebuild.sh`
Quickly rebuild current configuration, restart hyprland and waybar
### `update.sh`
Backup current flake, update and do `rebuild.sh`
## Keybinds
| Keys | Action | Notes |
| ------------- | -------------- | -------------- |
| `SUPER + E` | Terminal | foot |
| `SUPER + SHIFT + E` | Terminal | Floating window |
| `SUPER + B` | Browser | firefox |
| `SUPER + SHIFT + B` | Resource monitor | btop |
| `SUPER + D` | Discord client | vesktop |
| `SUPER + O` | Obsidian | |
| `SUPER + P` | Prism launcher | |
| `SUPER + Q` | File manager | thunar |
| `SUPER + S` | Steam | |
| `SUPER + X` | Calculator | `bc -lq` |
| `SUPER + SPACE` | App launcher | rofi |
| `SUPER + R` | Emoji selector | rofi-emoji |
| `SUPER + SHIFT + R` | Nerd emoji selector | rofi-nerdy |
| `SUPER + Z` | Clipboard history | cliphist |
| `SUPER + SHIFT + Z` | Zalgo text | Text → T̷͎ͯ͟ȩ̮̓ͭx̡̫̣̽t̺̋̿̓ |
| `PrintScreen` | Ss | `grimblast -nf copy screen` |
| `SHIFT + PrintScreen` | Ss → swappy | Quick editing |
| `SUPER + LCtrl` | Ss area | `grimblast -nf copy area` |
| `SUPER + SHIFT + LCtrl` | Ss area → swappy | Quick editing |
| `SUPER + I` | Color picker | hyprpicker |
| `SUPER + C` | Close program | SIGTERM |
| `SUPER + SHIFT + C` | Force close program | SIGKILL |
| `SUPER + F` | Toggle fullscreen | |
| `SUPER + SHIFT + F` | Toggle gamemode | Removes decorations, applies gamemoded |
| `SUPER + V` | Toggle floating | |
| `SUPER + G` | Toggle split | |
| `SUPER + SHIFT + G` | Pseudo tile | |
| `SUPER + <N>` | Switch to workspace | |
| `SUPER + SHIFT + <N>` | Move window to workspace | |
| `SUPER + H/J/K/L` | Move focus | |
| `SUPER + SHIFT + H/J/K/L` | Resize window | |
