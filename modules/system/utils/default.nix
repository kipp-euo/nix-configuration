{ pkgs, ... }:
{
  programs.bandwhich.enable = true;

  programs.wireshark.enable = true;
  users.users."kipp".extraGroups = [ "wireshark" ];
  
  environment.systemPackages = with pkgs; [
    # terminal/shell
    compsize
    curl
    ffmpeg
    file
    jq
    killall
    lm_sensors
    man-db
    neovim
    nix-index
    wget

    # GUI
    gnome-disk-utility
    gparted

    # What is my ISP doing again?
    bandwhich
    bmon
    curl
    dig
    dnsutils
    doggo
    drill
    ethtool
    iftop
    ldns
    mtr
    netcat
    ngrep
    nmap
    socat
    tcpdump
    wireshark
    wireshark-cli
  ];
}
