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
          config.flake.nixosModules.workstation
          ({ config, ... }: {
            networking.hostName = "trolovo";
            fileSystems."/" = {
              device = "/dev/disk/by-label/nixos";
              fsType = "ext4";
            };
            boot.loader.systemd-boot = {
              enable = true;
            };

            boot.extraModulePackages = with config.boot.kernelPackages; [ ryzen_smu ];

            bpletza.workstation.enable = true;
          })
        ];
      };

      zocknix = nixos {
        system = "x86_64-linux";
        modules = [
          config.flake.nixosModules.default
          config.flake.nixosModules.home
          config.flake.nixosModules.workstation
          ({ ... }: {
            networking.hostName = "zocknix";
            fileSystems."/" = {
              device = "/dev/disk/by-label/nixos";
              fsType = "ext4";
            };
            boot.loader.systemd-boot = {
              enable = true;
            };

            bpletza.workstation = {
              enable = true;
              nvidia = true;
            };
          })
        ];
      };
    };
}
