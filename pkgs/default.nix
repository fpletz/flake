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
          version = "0.18.3-unstable-2025-11-25";
          src = src.override {
            rev = "abf80b529e48823e21215a6ccc4653e2c2a4a565";
            hash = "sha256-VJzFkh/UnJgHfTnt6DvQwRsvTV7jQZEaQiWludhs4Zk=";
          };
          patches = [ ];
        }
      );

      sway-unwrapped = prev.sway-unwrapped.overrideAttrs (
        { src, ... }:
        {
          version = "0.12-unstable-2025-11-28";
          src = src.override {
            rev = "f4aba22582184c9a4a20fd7a9ffd70c63b4b393d";
            hash = "sha256-2k4M3H5E4+9QVR7uV2+R834fiA8vFNjUSDEZpR0fM/I=";
          };
        }
      );

      librewolf-unwrapped = prev.librewolf-unwrapped.override (attrs: {
        onnxruntime = attrs.onnxruntime.override (_: {
          cudaSupport = false;
        });
      });

      hwloc = prev.hwloc.override (_: {
        enableCuda = false;
      });

      linuxPackages-xanmod = final.linuxPackagesFor final.linux-xanmod;
    }
    // byNamePackages final;
}
