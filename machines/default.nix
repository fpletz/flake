{ config, withSystem, inputs, ... }:
{
  flake.nixosConfigurations =
    let
      nixos = { system, modules }: withSystem system (
        { config, inputs', ... }:
        inputs.nixpkgs.lib.nixosSystem {
          inherit system modules;
          specialArgs = {
            packages = config.packages;
            inherit inputs inputs';
          };
        }
      );
    in
    {
      trolovo = nixos {
        system = "x86_64-linux";
        modules = [
          config.flake.nixosModules.default
          config.flake.nixosModules.home
          ({ packages, pkgs, ... }: {
            networking.hostName = "trolovo";
            fileSystems."/" = {
              device = "/dev/disk/by-label/nixos";
              fsType = "ext4";
            };
            boot.loader.systemd-boot = {
              enable = true;
            };

            boot.kernelPackages = pkgs.linuxPackagesFor packages.linux-xanmod;
          })
        ];
      };
    };
}
