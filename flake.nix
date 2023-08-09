{
  description = "fpletz flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nixpkgs-stable.follows = "nixpkgs";
      };
    };
  };

  outputs = {
    self,
    nixpkgs,
    pre-commit-hooks,
    ...
  }: let
    supportedSystems = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    packages = ["wofi-emoji"];
    forAllPackages = nixpkgs.lib.genAttrs packages;
  in {
    overlays.default = final: prev:
      forAllPackages (
        pkgname:
          final.callPackage (./pkgs + "/${pkgname}.nix") {}
      );

    legacyPackages = forAllSystems (system: nixpkgs.legacyPackages.${system}.extend self.overlays.default);

    packages =
      forAllSystems (system:
        forAllPackages (pkgname: self.legacyPackages.${system}.${pkgname}));

    formatter = forAllSystems (
      system:
        nixpkgs.legacyPackages.${system}.alejandra
    );

    checks = forAllSystems (
      system: {
        pre-commit-check = pre-commit-hooks.lib.${system}.run {
          src = self;
          hooks = {
            alejandra.enable = true;
            statix.enable = true;
            nil.enable = true;
          };
        };
      }
    );
  };
}
