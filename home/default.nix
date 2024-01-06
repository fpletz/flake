{ inputs, ... }:
{
  flake.homeConfigurations =
    let
      inherit (inputs.home-manager.lib) homeManagerConfiguration;
    in
    {
      fpletz = homeManagerConfiguration {
        pkgs = import inputs.nixpkgs { };
        modules = [
          ./fpletz.nix
        ];
      };
    };
}
