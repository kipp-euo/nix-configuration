rec {
  # Change these
  username = "kipp";
  host = "laptop";


  home = "/home/${username}";
  config_dir = "${home}/nix-configuration";

  hosts = { pc = "pcbg"; laptop = "laptop"; };
  hostname = hosts.${host};
}
