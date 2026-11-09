rec {
  # Change these
  username = "kipp";
  host = "pc";

  locale = "ru_RU.UTF-8";


  home = "/home/${username}";
  config_dir = "${home}/nix-configuration";
  downloads_dir = "${home}/Downloads";
  documents_dir = "${home}/Documents";
  media_dir = "${home}/Media";
  applications_dir = "${home}/Applications";

  hosts = { pc = "pcbg"; laptop = "laptop"; };
  hostname = hosts.${host};
}
