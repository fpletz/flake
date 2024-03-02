{
  description = "fpletz flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    flake-parts.url = "github:hercules-ci/flake-parts";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
    nixvim = {
      #url = "github:nix-community/nixvim";
      url = "github:traxys/nixvim/codesniffer";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        home-manager.follows = "home-manager";
        pre-commit-hooks.follows = "pre-commit-hooks";
      };
    };
    nix-colors = {
      url = "github:misterio77/nix-colors";
      inputs.nixpkgs-lib.follows = "flake-parts/nixpkgs-lib";
    };
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      imports = [
        ./pkgs
        ./machines
        ./home
        ./treefmt.nix
      ];

      flake =
        let
          modules = {
            default = ./nixos/default.nix;
            home = ./nixos/home.nix;
            workstation = ./nixos/workstation.nix;
          };
          all = { imports = builtins.attrValues modules; };
        in
        {
          nixosModules = modules // {
            inherit all;
          };
        };

      perSystem = { pkgs, config, lib, ... }: {
        devShells.default = pkgs.mkShellNoCC {
          packages = [
            config.treefmt.build.wrapper
          ] ++ (lib.attrValues config.treefmt.build.programs);
          shellHook = ''
            ${config.pre-commit.installationScript}
          '';
        };
      };
    };
}
