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
        version = "0-unstable-2024-10-20";
        src = final.fetchFromGitHub {
          owner = "swaywm";
          repo = "sway";
          rev = "a63027245a6805bb952e47c5751ecdd7d1063d2f";
          hash = "sha256-5/1oVqORWTYHWpxMhgV+n1ORE2d7YkMtVjdtw9KgQ+U=";
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
        version = "0-unstable-2024-10-15";
        src = final.fetchFromGitLab {
          domain = "gitlab.freedesktop.org";
          owner = "wlroots";
          repo = "wlroots";
          rev = "47fb00f66d5a8367d0108bd960f99e51ab1a1318";
          hash = "sha256-HkpTML14tbYBLiHkqoFRSn/qKsVny/oso2TuG6LY/fk=";
        };
      });
    }
    // lib.filesystem.packagesFromDirectoryRecursive {
      inherit (final) callPackage;
      directory = ./by-name;
    };
}
