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
        directory = ./by-name;
      };

      legacyPackages = pkgs;
    };

  flake.overlays.default =
    final: prev:
    {
      linuxPackages-xanmod = final.linuxPackagesFor final.linux-xanmod;
      opencv = prev.opencv.override { enableCuda = false; };
      sway-unwrapped = prev.sway-unwrapped.overrideAttrs (attrs: {
        version = "0-unstable-2024-09-21";
        src = final.fetchFromGitHub {
          owner = "swaywm";
          repo = "sway";
          rev = "63345977e2c411359a049c40cf2c1044a22b4f4a";
          hash = "sha256-nDq5422boRMGDCyJhw4ArJKlgHPNBAx5B9GKTaj+A/U=";
        };
        buildInputs = attrs.buildInputs ++ [ final.wlroots ];
        mesonFlags =
          let
            inherit (lib.strings) mesonEnable mesonOption;
          in
          [
            (mesonOption "sd-bus-provider" "libsystemd")
            (mesonEnable "tray" attrs.trayEnabled)
          ];
      });
      wlroots = prev.wlroots.overrideAttrs (_attrs: {
        version = "0-unstable-2024-09-24";
        src = final.fetchFromGitLab {
          domain = "gitlab.freedesktop.org";
          owner = "wlroots";
          repo = "wlroots";
          rev = "a8d1e5273abad02e594c4ad2f237a204ca239528";
          hash = "sha256-u1YttUkeA/vplXuQs27K38uqDZyBxXZHcbqz7ywRrVY=";
        };
      });
    }
    // lib.filesystem.packagesFromDirectoryRecursive {
      inherit (final) callPackage;
      directory = ./by-name;
    };
}
