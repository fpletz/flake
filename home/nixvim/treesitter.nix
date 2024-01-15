{
  programs.nixvim = {
    colorschemes.catppuccin.integrations.treesitter = true;

    plugins = {
      treesitter = {
        enable = true;
        indent = true;
        #folding = true;
      };
      treesitter-refactor = {
        enable = true;
        highlightCurrentScope.enable = true;
        highlightDefinitions.enable = true;
      };
    };
  };
}
