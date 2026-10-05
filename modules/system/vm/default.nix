{ pkgs, ... }:
{
  boot.kernelModules = [ "kvm-intel" ]; 
  users.users."kipp".extraGroups = [ "kvm" ];
  environment.systemPackages = with pkgs; [
    qemu
    quickemu
  ];
}
