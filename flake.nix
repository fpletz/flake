{
  description = "fpletz flake";

  inputs = {
    nixpkgs.url = "github:fpletz/nixpkgs/master";

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-root.url = "github:srid/flake-root";
    flake-compat.url = "github:edolstra/flake-compat";

    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.91.1-1.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nixpkgs-stable.follows = "nixpkgs";
        flake-compat.follows = "flake-compat";
      };
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        flake-compat.follows = "flake-compat";
        home-manager.follows = "home-manager";
        git-hooks.follows = "git-hooks";
      };
    };

    nix-colors = {
      url = "github:misterio77/nix-colors";
      inputs.nixpkgs-lib.follows = "flake-parts/nixpkgs-lib";
    };

    bad_gateway = {
      url = "github:mguentner/bad_gateway";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixd = {
      url = "github:nix-community/nixd/release/2.x";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        flake-root.follows = "flake-root";
      };
    };

    openwrt-imagebuilder = {
      url = "github:astro/nix-openwrt-imagebuilder";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "flake-compat";
      };
    };
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      debug = true;
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      imports = [
        inputs.flake-root.flakeModule
        ./pkgs
        ./openwrt
        ./machines
        ./home
        ./treefmt.nix
      ];

      flake.nixosModules =
        let
          modules = {
            default = ./nixos/default.nix;
            hardware = ./nixos/hardware.nix;
            home = ./nixos/home.nix;
            nixpkgs = ./nixos/nixpkgs.nix;
            workstation = ./nixos/workstation.nix;
          };
          all = {
            imports = (builtins.attrValues modules) ++ [ inputs.lix-module.nixosModules.default ];
          };
        in
        modules // { inherit all; };

      perSystem =
        { pkgs, config, ... }:
        {
          devShells.default = pkgs.mkShellNoCC {
            packages = [
              pkgs.sops
              pkgs.nix-fast-build
            ];

            inputsFrom = [
              config.flake-root.devShell
              config.treefmt.build.devShell
              config.pre-commit.devShell
            ];
          };

          apps = {
            generate-dircolors.program = pkgs.writers.writeBashBin "generate-dircolors" ''
              ${pkgs.vivid}/bin/vivid generate tokyonight-night | \
                ${pkgs.python3}/bin/python3 -c 'import sys, json; print(json.dumps(dict([s.split("=") for s in sys.stdin.read().strip().split(":")])))' \
                > static/dircolors.json
            '';
          };
        };
    };
}
