{ inputs, ... }:
{
  imports = [ inputs.home-manager.flakeModules.home-manager ];
  flake.homeConfigurations =
    let
      inherit (inputs.home-manager.lib) homeManagerConfiguration;
    in
    {
      fpletz = homeManagerConfiguration {
        pkgs = import inputs.nixpkgs { };
        extraSpecialArgs = {
          inherit inputs;
          osConfig = { };
        };
        modules = [ ./fpletz.nix ];
      };
    };
}
