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
      linuxPackages-xanmod = (final.linuxPackagesFor final.linux-xanmod).extend (
        final: _prev: { ryzen_smu = final.callPackage ./ryzen_smu.nix { }; }
      );
      sway-unwrapped = prev.sway-unwrapped.overrideAttrs (attrs: {
        version = "0-unstable-2024-08-18";
        src = final.fetchFromGitHub {
          owner = "swaywm";
          repo = "sway";
          rev = "ae7c1b139a3c71d3e11fe2477d8b21c36de6770e";
          hash = "sha256-U7IoChVLxGQZ/giTd2B7ubcIIr8gTIPSH6PAPgz8WaQ=";
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
        version = "0-unstable-2024-08-18";
        src = final.fetchFromGitLab {
          domain = "gitlab.freedesktop.org";
          owner = "wlroots";
          repo = "wlroots";
          rev = "a0450d219fbc8a453876e70f29b9b5c2f76b0c64";
          hash = "sha256-DkQX2mQcsiDUlaEECBM0i5ERHWp62clOzKqYpVBB9UA=";
        };
      });
    }
    // lib.filesystem.packagesFromDirectoryRecursive {
      inherit (final) callPackage;
      directory = ./by-name;
    };
}
