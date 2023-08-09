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
    forAllSelfPackages = nixpkgs.lib.genAttrs ["wofi-emoji"];
    forAllLegacyPackages = f: forAllSystems (system: f self.legacyPackages.${system});
  in {
    overlays.default = final: prev:
      forAllSelfPackages (
        pkgname:
          final.callPackage (./pkgs + "/${pkgname}.nix") {}
      );

    legacyPackages = forAllSystems (system:
      nixpkgs.legacyPackages.${system}.extend self.overlays.default
    );

    devShells = forAllLegacyPackages (pkgs: {
      default = pkgs.mkShell {
        packages = [
          pkgs.nil
          pkgs.alejandra
        ];
      };
    });

    packages =
      forAllSystems (system:
        forAllSelfPackages (pkgname: self.legacyPackages.${system}.${pkgname}));

    formatter = forAllLegacyPackages (pkgs: pkgs.alejandra);

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
