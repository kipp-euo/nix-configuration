{ pkgs, vars, ... }:
{
  boot.kernelModules = if "${vars.host}" == "pc" then [ "kvm-intel" ] else [];
  users.users.${vars.username}.extraGroups = [ "kvm" ];
  environment.systemPackages = with pkgs; [
    qemu
    quickemu
  ];
}
