{ lib, inputs, ... }:
{
  perSystem =
    { pkgs, system, ... }:
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [
          inputs.self.overlays.default
          inputs.lix-module.overlays.default
        ];
      };

      packages = lib.filesystem.packagesFromDirectoryRecursive {
        inherit (pkgs) callPackage;
        directory = ./pkgs;
      };
    };

  flake.overlays.default =
    final: _prev:
    {
      linuxPackages-xanmod = (final.linuxPackagesFor final.linux-xanmod).extend (
        final: _prev: { ryzen_smu = final.callPackage ../pkgs/ryzen_smu.nix { }; }
      );
    }
    // lib.filesystem.packagesFromDirectoryRecursive {
      inherit (final) callPackage;
      directory = ./pkgs;
    };
}
