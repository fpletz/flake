{ lib, osConfig, ... }:
{
  config.programs.nixvim.plugins.none-ls = lib.mkIf osConfig.bpletza.workstation.enable {
    enable = false;
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
        nixpkgs_fmt.enable = true;
        shfmt.enable = true;
      };
    };
  };
}
