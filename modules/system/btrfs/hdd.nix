{ ... }:
let
  mount_options = [ "compress=zstd:3" "space_cache=v2" "discard=async" "noatime" ];
in
{
  fileSystems = {
    "/home/kipp/.local/share/SteamHDD".options = mount_options;
    "/home/kipp/Storage".options = mount_options;
  };
}
