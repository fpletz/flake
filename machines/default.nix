{ config, inputs, ... }:
{
  flake.nixosConfigurations =
    let
      inherit (inputs.nixpkgs.lib) nixosSystem;
      nixos = { system, modules }: nixosSystem {
        inherit system modules;
        specialArgs = { inherit inputs; };
      };
    in
    {
      trolovo = nixos {
        system = "x86_64-linux";
        modules = [
          config.flake.nixosModules.default
          config.flake.nixosModules.home
          {
            networking.hostName = "trolovo";
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
    };
}
