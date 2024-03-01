{
  config.programs.nixvim.plugins.none-ls = {
    enable = true;
    enableLspFormat = true;
    sources = {
      code_actions = {
        gitsigns.enable = true;
        statix.enable = true;
      };
      diagnostics = {
        deadnix.enable = true;
      };
      formatting = {
        isort.enable = true;
        nixpkgs_fmt.enable = true;
        shfmt.enable = true;
      };
    };
  };
}
