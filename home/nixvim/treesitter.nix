{
  programs.nixvim = {
    colorschemes.catppuccin.integrations.treesitter = true;

    plugins = {
      treesitter = {
        enable = true;
        indent = true;
        #folding = true;
      };
      refactoring = {
        enable = true;
      };
    };
  };
}
