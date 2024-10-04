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
        version = "0-unstable-2024-10-03";
        src = final.fetchFromGitHub {
          owner = "swaywm";
          repo = "sway";
          rev = "c90cb37b2a0861548461daa9b75d75317e01b679";
          hash = "sha256-zU9WqY2p0GQ29/MyF5k10vGv7a+QcVk/TIE0hJmzu1c=";
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
        version = "0-unstable-2024-10-03";
        src = final.fetchFromGitLab {
          domain = "gitlab.freedesktop.org";
          owner = "wlroots";
          repo = "wlroots";
          rev = "7ce868bcf6593941669bedbd1be8ea7cc9205da2";
          hash = "sha256-oC7eN/8xYb+r/Z27jNaQGgTOdFkWmYtN75wjWO4kUw4=";
        };
      });
    }
    // lib.filesystem.packagesFromDirectoryRecursive {
      inherit (final) callPackage;
      directory = ./by-name;
    };
}
