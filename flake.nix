{
  description = "fpletz flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-root.url = "github:srid/flake-root";
    flake-compat.url = "github:edolstra/flake-compat";

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
        flake-root.follows = "flake-root";
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
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      imports = [
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
            workstation = ./nixos/workstation.nix;
          };
          all = {
            imports = builtins.attrValues modules;
          };
        in
        modules // { inherit all; };

      perSystem =
        {
          pkgs,
          config,
          lib,
          ...
        }:
        {
          formatter = pkgs.nixfmt-rfc-style;
          devShells.default = pkgs.mkShellNoCC {
            packages = [ config.treefmt.build.wrapper ] ++ (lib.attrValues config.treefmt.build.programs);
            shellHook = ''
              ${config.pre-commit.installationScript}
            '';
          };

          pre-commit = {
            check.enable = true;
            settings.hooks.treefmt = {
              enable = true;
              package = config.treefmt.build.wrapper;
            };
          };

          apps = {
            generate-dircolors.program =
              let
                # vivid master with working tokyonight theme
                vivid = pkgs.vivid.overrideAttrs (attrs: rec {
                  version = "unstable-2024-01-16";
                  src = attrs.src.override (_: {
                    rev = "2ddbc2f344b30451a995beb6489b583ca23cac4f";
                    hash = "sha256-LLjLGCuIaH1idKY7lu8HNW3lasio9nkMi0E0rOxUmoY=";
                  });
                  patches = [
                    (pkgs.fetchpatch {
                      url = "https://github.com/sharkdp/vivid/commit/ea15b24586fbe5f82aee403fc9d5f9eaa9e77792.patch";
                      revert = true;
                      hash = "sha256-Jp/Qh4aARUhzs49fJx+flO5oBjX9yWWrNKQe7/IATCc=";
                    })
                  ];
                  cargoDeps = attrs.cargoDeps.overrideAttrs (_: {
                    inherit src;
                    outputHash = "sha256-prOPY9sYh7CYE35WLXaavsNcbeYajYdnJ2t4jjc/AX4=";
                  });
                });
              in
              pkgs.writers.writeBashBin "generate-dircolors" ''
                ${vivid}/bin/vivid generate tokyonight-night | \
                  ${pkgs.python3}/bin/python3 -c 'import sys, json; print(json.dumps(dict([s.split("=") for s in sys.stdin.read().strip().split(":")])))' \
                  > static/dircolors.json
              '';
          };
        };
    };
}
