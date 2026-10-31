{ pkgs, vars, ... }:
{
  home.sessionVariables = {
    VISUAL = "nvim";
    MANPAGER = "nvim +Man!";
  };
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    plugins = with pkgs.vimPlugins; [
      friendly-snippets
      mini-icons
      nvim-web-devicons
      telescope-ui-select-nvim
      {
        plugin = nvim-highlight-colors;
        config = "require('nvim-highlight-colors').setup({})";
      }
      {
        plugin = oil-nvim;
        config = builtins.readFile ./config/plugins/oil.lua;
      }
      {
        plugin = blink-cmp;
        config = builtins.readFile ./config/plugins/blink.lua;
      }
      {
        plugin = nvim-lspconfig;
        config = builtins.readFile ./config/plugins/lspconfig.lua;
      }
      {
        plugin = nvim-treesitter.withAllGrammars;
        config = builtins.readFile ./config/plugins/treesitter.lua;
      }
      {
        plugin = telescope-nvim;
        config = builtins.readFile ./config/plugins/telescope.lua;
      }
      {
        plugin = lualine-nvim;
        config = builtins.readFile ./config/plugins/lualine.lua;
      }
      {
        plugin = which-key-nvim;
        config = builtins.readFile ./config/plugins/which-key.lua;
      }
      {
        plugin = conform-nvim;
        config = builtins.readFile ./config/plugins/conform.lua;
      }
      {
        plugin = gitsigns-nvim;
        config = builtins.readFile ./config/plugins/gitsigns.lua;
      }
    ];
    initLua = builtins.foldl' (x: y: x + "\n" + y + "\n") "" [
      (builtins.readFile ./config/options.lua)
      (builtins.readFile ./config/colors.lua)
      ''
        vim.g.nix_config_dir = "${vars.config_dir}"
        vim.g.nix_host = "${vars.host}"
      ''
    ];
  };
  xdg.configFile."nvim/after/ftplugin".source = ./config/after/ftplugin;
  home.packages = with pkgs; [
    tree-sitter
    ripgrep
    fd

    # LSP
    bash-language-server
    clang-tools
    docker-language-server
    lua-language-server
    marksman
    nixd
    basedpyright
    rust-analyzer
    jdt-language-server
    systemd-lsp
    texlab
    vscode-langservers-extracted

    # CLI-formatters
    stylua
    ruff
    shfmt
    prettier
    nixfmt
    rustfmt
  ];
}
