{ inputs, pkgs, ... }:
{
  home.packages = [ inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.nvim ];

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  programs = {
    bash.shellAliases.vimdiff = "nvim -d";
    fish.shellAliases.vimdiff = "nvim -d";
    zsh.shellAliases.vimdiff = "nvim -d";
  };
}
