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
      }
      // byNamePackages pkgs;
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
      keepassxc = prev.keepassxc.override {
        withKeePassX11 = false;
        withKeePassYubiKey = false;
      };
      wlroots_0_19 = prev.wlroots_0_19.overrideAttrs (
        { src, ... }:
        {
          version = "0.19.2-unstable-2025-10-17";
          src = src.override {
            rev = "6d63871f059192b15d2fa0dfacfb391709f4952d";
            hash = "sha256-LShsqWJ96lF8FoVvfatSfmizatOKGlyFUHlxtD3E5pQ=";
          };
          patches = [ ];
        }
      );
      sway-unwrapped = prev.sway-unwrapped.overrideAttrs (
        { src, ... }:
        {
          version = "0.12-unstable-2025-10-05";
          src = src.override {
            rev = "90d3270970cc963454455b572883a051d3f376a1";
            hash = "sha256-X/JYV5lBfi4xnRA8d8bk/+DTaC2UWasNOBz3KYFMFUU=";
          };
        }
      );

      linuxPackages-xanmod = final.linuxPackagesFor final.linux-xanmod;
    }
    // byNamePackages final;
}
