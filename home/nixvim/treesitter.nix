{
  programs.nixvim = {
    colorschemes.catppuccin.integrations.treesitter = true;

    plugins = {
      treesitter = {
        enable = true;
        indent = true;
        nixvimInjections = true;
        incrementalSelection.enable = true;
      };
      treesitter-refactor = {
        enable = true;
        highlightDefinitions.enable = true;
      };
      ts-autotag = {
        enable = true;
      };
    };
  };
}
