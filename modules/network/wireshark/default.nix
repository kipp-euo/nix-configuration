{ vars, ... }:
{
  programs.wireshark.enable = true;
  users.users.${vars.username}.extraGroups = [ "wireshark" ];
}
