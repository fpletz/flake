{ lib, inputs, ... }:
let
  byNamePackages =
    pkgs:
    lib.filesystem.packagesFromDirectoryRecursive {
      inherit (pkgs) callPackage;
      directory = ./by-name;
    };
in
{
  perSystem =
    { pkgs, system, ... }:
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [
          inputs.self.overlays.default
          inputs.nixd.overlays.default
        ];
      };

      packages = {
        nvim = inputs.nixvim.legacyPackages.${system}.makeNixvimWithModule {
          inherit pkgs;
          module = import ../home/nixvim;
        };
      } // byNamePackages pkgs;

      legacyPackages = pkgs;
    };

  flake.overlays.default =
    final: prev:
    {
      linuxPackages-xanmod = final.linuxPackagesFor final.linux-xanmod;
      swww = prev.swww.overrideAttrs (
        {
          patches ? [ ],
          ...
        }:
        {
          patches =
            patches
            ++ lib.singleton (
              final.fetchpatch {
                url = "https://github.com/LGFae/swww/commit/b5116969245f1994d80bb319c54ab85d4cd6aaf4.patch";
                hash = "sha256-R+4G7prEu1f1zlHQJbMGUv48TQeVuseK/H23aQKWv7I=";
              }
            );
        }
      );
    }
    // byNamePackages final;
}
