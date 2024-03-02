{
  config.programs.nixvim.plugins.none-ls = {
    enable = true;
    enableLspFormat = true;
    sources = {
      code_actions = {
        gitrebase.enable = true;
        statix.enable = true;
      };
      diagnostics = {
        actionlint.enable = true;
        alex.enable = true;
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
