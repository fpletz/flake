{ lib, inputs, ... }:
{
  perSystem = { pkgs, system, ... }:
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [
          inputs.self.overlays.default
        ];
      };

      packages =
        let
          forAllSelfPackages = lib.genAttrs [
            "wofi-emoji"
            "systemd-lock-handler"
            "wayidle"
            "usbguard-notifier"
            "caffeinated"
            "linux-xanmod"
          ];
        in
        forAllSelfPackages (
          pkgname:
          pkgs.callPackage (./. + "/${pkgname}.nix") { }
        );
    };

  flake.overlays.default = final: _prev:
    {
      linux-xanmod = final.callPackage ./linux-xanmod.nix { };
      linuxPackages-xanmod = (final.linuxPackagesFor final.linux-xanmod).extend
        (final: _prev: {
          ryzen_smu = final.callPackage ../pkgs/ryzen_smu.nix { };
        });
    };
}
