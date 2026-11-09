{ vars, ... }:
let
  mount_options = [ "compress=zstd:3" "space_cache=v2" "noatime" ];
in
{
  fileSystems = {
    "${vars.home}/.local/share/SteamHDD".options = mount_options;
    "${vars.home}/Storage".options = mount_options;
  };
}
