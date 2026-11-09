{ vars, ... }:
{
  users.users.${vars.username} = {
    isNormalUser = true;
    description = "User";
    extraGroups = [ "networkmanager" "wheel" ];
  };
  home-manager.users.${vars.username} = {
    home = {
      username = "${vars.username}";
      homeDirectory = "${vars.home}";
      sessionPath = [ "${vars.home}/.local/bin" ];
    };
  };
}
