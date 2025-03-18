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
      _module.args.pkgs = lib.foldl (p: p.extend) inputs.nixpkgs.legacyPackages.${system} [
        inputs.self.overlays.default
        inputs.lix-module.overlays.default
        inputs.nil.overlays.default
      ];

      packages = {
        nvim = inputs.nixvim.legacyPackages.${system}.makeNixvimWithModule {
          inherit pkgs;
          module = import ../home/nixvim;
        };
      } // byNamePackages pkgs;

      legacyPackages = pkgs;
    };

  flake.overlays.default =
    final: _prev:
    {
      linuxPackages-xanmod = final.linuxPackagesFor final.linux-xanmod;
    }
    // byNamePackages final;
}
