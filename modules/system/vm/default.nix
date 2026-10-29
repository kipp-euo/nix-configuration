{ pkgs, vars, ... }:
{
  boot.kernelModules = [ "kvm-intel" ]; 
  users.users.${vars.username}.extraGroups = [ "kvm" ];
  environment.systemPackages = with pkgs; [
    qemu
    quickemu
  ];
}
