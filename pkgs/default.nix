{ lib, ... }:
{
  perSystem = { pkgs, ... }:
    {
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
}
