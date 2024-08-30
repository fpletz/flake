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
      sway-unwrapped = prev.sway-unwrapped.overrideAttrs (attrs: {
        version = "0-unstable-2024-08-19";
        src = final.fetchFromGitHub {
          owner = "swaywm";
          repo = "sway";
          rev = "f9c0f043e5ec39574c9d9b0fb3dece6169a0e67d";
          hash = "sha256-1kFgXLG1pZ/eMTNzSsx0wYDVz3Q6hUFrjDEeM7QmyZY=";
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
        version = "0-unstable-2024-08-20";
        src = final.fetchFromGitLab {
          domain = "gitlab.freedesktop.org";
          owner = "wlroots";
          repo = "wlroots";
          rev = "098cb9b7a3d7c7a8b1633809e04c9bcf34a33784";
          hash = "sha256-7dAW+t0S2BAuS6dEdCM0bn8jYtIyspZrawrJuY1jnE0=";
        };
      });
    }
    // lib.filesystem.packagesFromDirectoryRecursive {
      inherit (final) callPackage;
      directory = ./by-name;
    };
}
