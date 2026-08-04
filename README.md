# A simple NixOS configuration with Hyprland
## Structure
- `assets/`
  - `fastfetchLogos/`
  - `wallpapers/`
- `hosts/`
  - `example/`
    - `configuration.nix`
    - `hardware-configuration.nix`
  - ...
- `lock_backups/`
  - `flake.lock.2000.01.01-a1b2c3d.back`
  - ...
- `modules/`
  - `home/`                        (configured with home-manager)
    - `module/`
      - `default.nix`
    - `another_module/`
      - `config/`                 (usually symlinked to ~/.config/another_module)
      - `default.nix`
    - ...
    - `home.nix`                  (home module imports)
  - `system/`
    - `module/`
      - `default.nix`
    - ...
    - `system.nix`                (system module imports)
## Scripts
### `rebuild.sh`
Quickly rebuild current configuration, restart hyprland and waybar
### `update.sh`
Backup current flake, update and do `rebuild.sh`
