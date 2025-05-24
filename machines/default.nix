{
  self,
  withSystem,
  inputs,
  ...
}:
{
  # FIXME: these are only used for testing, not for actual deployment
  flake.nixosConfigurations =
    let
      nixos =
        {
          system,
          modules ? [ ],
          module ? null,
        }:
        withSystem system (
          { config, inputs', ... }:
          inputs.nixpkgs.lib.nixosSystem {
            inherit system;
            modules =
              if modules != [ ] then
                modules
              else
                [
                  self.nixosModules.all
                  module
                ];
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
        module = {
          networking.hostName = "server";
          fileSystems."/" = {
            device = "/dev/disk/by-label/nixos";
            fsType = "ext4";
          };
          boot.loader.systemd-boot = {
            enable = true;
          };
        };
      };

      ananas = nixos {
        system = "x86_64-linux";
        module = import ./ananas.nix;
      };

      hal = nixos {
        system = "aarch64-linux";
        module = {
          networking.hostName = "hal";
          fileSystems."/" = {
            device = "/dev/disk/by-label/nixos";
            fsType = "ext4";
          };
          boot.loader = {
            grub.enable = false;
            generic-extlinux-compatible.enable = true;
          };
        };
      };

      fpine = nixos {
        system = "aarch64-linux";
        module = {
          networking.hostName = "fpine";
          fileSystems."/" = {
            device = "/dev/disk/by-label/fpine-nixos";
            fsType = "ext4";
          };

          bpletza.hardware.pinebook-pro = {
            enable = true;
            efi = true;
          };
          bpletza.workstation.enable = true;
        };
      };

      trolovo = nixos {
        system = "x86_64-linux";
        module = import ./trolovo.nix;
      };

      lolnovo = nixos {
        system = "x86_64-linux";
        module = import ./lolnovo.nix;
      };

      zocknix = nixos {
        system = "x86_64-linux";
        module = {
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
            gaming = true;
          };
        };
      };
    };
}
