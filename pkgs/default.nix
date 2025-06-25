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
    };

  flake.overlays.default =
    final: prev:
    {
      tailscale = prev.tailscale.overrideAttrs (
        {
          patches ? [ ],
          ...
        }:
        {
          patches = patches ++ [ ../static/tailscale-magicdns-aaaa.patch ];
          doCheck = false;
        }
      );
      linuxPackages-xanmod = final.linuxPackagesFor final.linux-xanmod;
    }
    // byNamePackages final;
}
