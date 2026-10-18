{ inputs, ... }:
{
  imports = [
    inputs.treefmt-nix.flakeModule
    inputs.git-hooks.flakeModule
  ];

  perSystem =
    { lib, pkgs, ... }:
    {
      treefmt = {
        projectRootFile = "flake.lock";
        programs = {
          deadnix.enable = true;
          nixfmt.enable = true;
          nixf-diagnose.enable = true;
        };
      };

      pre-commit.settings.hooks = {
        treefmt.enable = true;
        commitlint = {
          enable = true;
          name = "commitlint-rs";
          package = pkgs.commitlint-rs;
          entry = "${lib.getExe pkgs.commitlint-rs} --config ${./.commitlintrc.yml} --edit";
          stages = [ "commit-msg" ];
          pass_filenames = true;
        };
      };
    };
}
