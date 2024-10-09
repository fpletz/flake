{
  programs.nixvim = {
    colorschemes.catppuccin.settings.integrations.treesitter = true;

    plugins = {
      treesitter = {
        enable = true;
        nixvimInjections = true;
        settings = {
          highlight.enable = true;
          indent.enable = true;
          incremental_selection.enable = true;
        };
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
