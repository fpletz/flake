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

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    pre-commit-hooks,
    home-manager,
    ...
  } @ inputs: let
    supportedSystems = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    forAllSelfPackages = nixpkgs.lib.genAttrs [
      "wofi-emoji"
      "systemd-lock-handler"
      "wayidle"
    ];
    forAllLegacyPackages = f: forAllSystems (system: f self.legacyPackages.${system});
  in {
    overlays.default = final: prev:
      forAllSelfPackages (
        pkgname:
          final.callPackage (./pkgs + "/${pkgname}.nix") {}
      );

    legacyPackages = forAllSystems (
      system:
        nixpkgs.legacyPackages.${system}.extend self.overlays.default
    );

    devShells = forAllLegacyPackages (pkgs: {
      default = pkgs.mkShellNoCC {
        packages = [
          pkgs.nil
          pkgs.alejandra
        ];
        inherit (self.checks.${pkgs.system}.pre-commit-check) shellHook;
      };
    });

    packages =
      forAllSystems (system:
        forAllSelfPackages (pkgname: self.legacyPackages.${system}.${pkgname}));

    homeConfigurations.fpletz = home-manager.lib.homeManagerConfiguration {
      modules = [
        ./home/default.nix
      ];
    };

    nixosConfigurations = let
      nixos = system: modules:
        nixpkgs.lib.nixosSystem {
          inherit system modules;
          specialArgs = {inherit inputs;};
        };
    in {
      lolnovo = nixos "x86_64-linux" [
        {
          imports = [
            ./nixos/default.nix
            ./nixos/home.nix
            {
              # FIXME
              boot.loader.grub = {
                enable = true;
                devices = ["/dev/disk/by-diskseq/1"];
              };
              fileSystems."/" = {
                device = "/dev/disk/by-label/nixos";
                fsType = "ext4";
              };
            }
          ];
          networking.hostName = "lolnovo";
        }
      ];
    };

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
