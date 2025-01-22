{
  lib,
  config,
  osConfig,
  inputs,
  pkgs,
  ...
}:
{
  options.bpletza.nixvim = lib.mkOption {
    type = lib.types.bool;
    default = osConfig.bpletza.workstation.enable;
  };

  config = lib.mkIf config.bpletza.nixvim {
    home.packages = [ inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.nvim ];

    home.sessionVariables = {
      EDITOR = "nvim";
    };

    home.shellAliases = {
      vim = "nvim";
      vimdiff = "nvim -d";
    };
  };
}
