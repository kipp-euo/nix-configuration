{ pkgs, ... }:
{
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    MANPAGER = "nvim +Man!";
  };
  xdg.mimeApps.defaultApplications."text/plain" = [ "nvim.desktop" ];
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    plugins = with pkgs.vimPlugins; [
      nvim-highlight-colors
      {
        plugin = blink-cmp;
        config = builtins.readFile ./config/plugins/blink.lua;
      }
      {
        plugin = nvim-lspconfig;
        config = builtins.readFile ./config/plugins/lspconfig.lua;
      }
      {
        plugin = treesitter-modules-nvim;
        config = builtins.readFile ./config/plugins/treesitter.lua;
      }
    ];
    initLua = builtins.foldl' (x: y: x + "\n" + y + "\n") "" [
      (builtins.readFile ./config/options.lua)
      (builtins.readFile ./config/colors.lua)
    ];
  };
  xdg.configFile."nvim/after/ftplugin".source = ./config/after/ftplugin;
  home.packages = with pkgs; [
    tree-sitter

    # LSP
    bash-language-server
    clang
    docker-language-server
    lua-language-server
    marksman
    nixd
    pyright
    rust-analyzer
    systemd-language-server
    texlab
    vscode-langservers-extracted
  ];
}
