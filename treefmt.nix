{ inputs, ... }:
{
  imports = [
    inputs.treefmt-nix.flakeModule
    inputs.git-hooks.flakeModule
  ];

  perSystem = {
    treefmt = {
      projectRootFile = "flake.lock";
      programs = {
        deadnix.enable = true;
        nixfmt.enable = true;
      };
    };

    pre-commit.settings.hooks = {
      treefmt.enable = true;
      nil.enable = false; # FIXME: doesn't use lix
    };
  };
}
