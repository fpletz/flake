{ lib, inputs, ... }:
{
  imports = [
    inputs.treefmt-nix.flakeModule
    inputs.git-hooks.flakeModule
  ];

  perSystem =
    { pkgs, ... }:
    {
      treefmt = {
        projectRootFile = "flake.lock";

        settings.formatter = {
          nix = {
            command = "sh";
            options = [
              "-eucx"
              ''
                # First deadnix
                ${lib.getExe pkgs.deadnix} --edit "$@"
                # Then fmt
                ${lib.getExe pkgs.nixfmt-rfc-style} "$@"
              ''
              "--"
            ];
            includes = [ "*.nix" ];
          };
        };
      };

      pre-commit.settings.hooks = {
        treefmt.enable = true;
        nil.enable = true;
      };
    };
}
