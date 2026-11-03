{ pkgs, ... }:
{
  # @WBVLess_bot

  # // Define main function (script entry)
  #
  # const prependRules = [
  #   // Add your custom domain rules or direct routes here
  #   "PROCESS-PATH-REGEX,.*firefox.*,DIRECT"
  # ];
  # function main(config, profileName) {
  #   const originalRules = config["rules"] || [];
  #   config["rules"] = prependRules.concat(originalRules);
  #   return config;
  # }

  programs.clash-verge = { 
    enable = true;
    package = pkgs.clash-verge-rev;
    serviceMode = true;
    tunMode = true;
    autoStart = true;
    group = "users";
  };
}

