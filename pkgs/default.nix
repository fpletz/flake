{ lib, inputs, ... }:
let
  forAllSelfPackages = lib.genAttrs [
    "ap6256-firmware"
    "caffeinated"
    "linux-xanmod"
    "systemd-lock-handler"
    "usbguard-notifier"
    "wayidle"
    "wofi-emoji"
  ];
in
{
  perSystem =
    { pkgs, system, ... }:
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [ inputs.self.overlays.default ];
      };

      packages = forAllSelfPackages (pkgname: pkgs.callPackage (./. + "/${pkgname}.nix") { });
    };

  flake.overlays.default =
    final: _prev:
    {
      linuxPackages-xanmod = (final.linuxPackagesFor final.linux-xanmod).extend (
        final: _prev: { ryzen_smu = final.callPackage ../pkgs/ryzen_smu.nix { }; }
      );
    }
    // forAllSelfPackages (pkgname: final.callPackage (./. + "/${pkgname}.nix") { });
}
