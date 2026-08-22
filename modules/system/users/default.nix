{ ... }:
{
  users.users."kipp" = {
    isNormalUser = true;
    description = "Kipp";
    extraGroups = [ "networkmanager" "wheel" ];
  };
}
