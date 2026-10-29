{ vars, ... }:
{
  users.users.${vars.username} = {
    isNormalUser = true;
    description = "User";
    extraGroups = [ "networkmanager" "wheel" ];
  };
}
