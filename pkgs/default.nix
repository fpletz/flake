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
          src,
          ...
        }:
        {
          version = "1.92.5";
          src = src.override (_: {
            hash = "sha256-S0aD+x8dUPHaNb5MdB41oeID/8eERB3FKKuuqlCqJkU=";
          });
          vendorHash = "sha256-jJSSXMyUqcJoZuqfSlBsKDQezyqS+jDkRglMMjG1K8g=";
          patches = patches ++ [ ../static/tailscale-magicdns-aaaa.patch ];
          doCheck = false;
        }
      );

      keepassxc = prev.keepassxc.override {
        withKeePassX11 = false;
        withKeePassYubiKey = false;
      };

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
