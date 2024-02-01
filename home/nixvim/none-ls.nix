{
  config.programs.nixvim.plugins.none-ls = {
    enable = true;
    sources = {
      code_actions = {
        gitsigns.enable = true;
        shellcheck.enable = true;
        statix.enable = true;
      };
      diagnostics = {
        shellcheck.enable = true;
      };
      formatting = {
        isort.enable = true;
        nixpkgs_fmt.enable = true;
        rustfmt.enable = true;
        shfmt.enable = true;
      };
    };
  };
}