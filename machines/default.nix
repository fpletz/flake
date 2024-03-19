{
  config,
  withSystem,
  inputs,
  ...
}:
{
  flake.nixosConfigurations =
    let
      nixos =
        { system, modules }:
        withSystem system (
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
      server = nixos {
        system = "x86_64-linux";
        modules = [
          config.flake.nixosModules.all
          {
            networking.hostName = "server";
            fileSystems."/" = {
              device = "/dev/disk/by-label/nixos";
              fsType = "ext4";
            };
            boot.loader.systemd-boot = {
              enable = true;
            };
          }
        ];
      };

      fpro = nixos {
        system = "aarch64-linux";
        modules = [
          config.flake.nixosModules.all
          {
            networking.hostName = "fpro";
            fileSystems."/" = {
              device = "/dev/disk/by-label/nixos";
              fsType = "ext4";
            };

            bpletza.hardware.pinebook-pro = true;
            bpletza.workstation.enable = true;
          }
        ];
      };
      trolovo = nixos {
        system = "x86_64-linux";
        modules = [
          config.flake.nixosModules.all
          {
            networking.hostName = "trolovo";
            fileSystems."/" = {
              device = "/dev/disk/by-label/nixos";
              fsType = "ext4";
            };
            boot.loader.systemd-boot = {
              enable = true;
            };

            bpletza.hardware.thinkpad.a485 = true;
            bpletza.workstation.enable = true;
          }
        ];
      };

      zocknix = nixos {
        system = "x86_64-linux";
        modules = [
          config.flake.nixosModules.all
          (
            { ... }:
            {
              networking.hostName = "zocknix";
              fileSystems."/" = {
                device = "/dev/disk/by-label/nixos";
                fsType = "ext4";
              };
              boot.loader.systemd-boot = {
                enable = true;
              };

              bpletza.hardware.cpu.amd = true;
              bpletza.workstation = {
                enable = true;
                nvidia = true;
              };
            }
          )
        ];
      };
    };
}
