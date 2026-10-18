{
  description = "fpletz flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    flake-root.url = "github:srid/flake-root";
    flake-compat.url = "github:NixOS/flake-compat";

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "flake-compat";
      };
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-anywhere = {
      url = "github:nix-community/nixos-anywhere";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nixos-stable.follows = "nixpkgs";
        disko.follows = "disko";
        treefmt-nix.follows = "treefmt-nix";
      };
    };

    terranix = {
      url = "github:terranix/terranix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
      };
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
      };
    };

    stylix = {
      url = "github:nix-community/stylix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
      };
    };

    bad_gateway = {
      url = "github:fpletz/bad_gateway";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    openwrt-imagebuilder = {
      url = "github:Astro/nix-openwrt-imagebuilder";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
      };
    };

    flexfox = {
      url = "git+https://github.com/yuuqilin/FlexFox.git";
      flake = false;
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
        inputs.flake-root.flakeModule
        ./pkgs
        ./openwrt
        ./machines
        ./home
        ./nixos
        ./treefmt.nix
        ./tf.nix
      ];

      perSystem =
        {
          pkgs,
          config,
          system,
          ...
        }:
        {
          apps.check = {
            type = "app";
            program = pkgs.lib.getExe (
              pkgs.writeShellApplication {
                name = "check";
                runtimeInputs = [ pkgs.nix-fast-build ];
                text = ''
                  nix-fast-build --no-nom --no-download "$@"
                '';
              }
            );
          };

          apps.update = {
            type = "app";
            program = pkgs.lib.getExe (
              pkgs.writeShellApplication {
                name = "update";
                runtimeInputs = [
                  pkgs.nix
                  pkgs.git
                  pkgs.jq
                  pkgs.coreutils
                ];
                text = ''
                  old=$(mktemp)
                  trap 'rm -f "$old"' EXIT
                  cp flake.lock "$old"

                  nix flake update "$@"

                  if git diff --quiet -- flake.lock; then
                    echo "flake.lock: nothing to update"
                    exit 0
                  fi

                  body=$(jq -nr --slurpfile o "$old" --slurpfile n flake.lock '
                    def locks(l):
                      l.nodes as $nodes
                      | l.nodes.root.inputs
                      | to_entries
                      | map(select(.value | type == "string"))
                      | map({key, value: ($nodes[.value].locked // {})})
                      | from_entries;
                    def id(x): x.rev // x.narHash // "unknown";
                    def short(x):
                      if x.rev then x.rev[0:7] else (x.narHash // "?")[0:14] end;
                    def date(x):
                      if x.lastModified then (x.lastModified | strftime("%Y-%m-%d")) else "?" end;
                    locks($o[0]) as $a
                    | locks($n[0]) as $b
                    | ([($a | keys[]), ($b | keys[])] | unique[]) as $k
                    | if $a[$k] == null then "- \($k): added (\(short($b[$k])))"
                      elif $b[$k] == null then "- \($k): removed"
                      elif id($a[$k]) == id($b[$k]) then empty
                      else "- \($k): \(short($a[$k])) -> \(short($b[$k])) (\(date($a[$k])) -> \(date($b[$k])))"
                      end
                  ')

                  git commit -m "chore(flake): update flake.lock" -m "$body" -- flake.lock
                '';
              }
            );
          };

          devShells.default = pkgs.mkShellNoCC {
            packages = [
              pkgs.sops
              pkgs.ssh-to-age
              pkgs.nix-fast-build
              inputs.nixos-anywhere.packages.${system}.default
              pkgs.nh
            ];

            inputsFrom = [
              config.flake-root.devShell
              config.treefmt.build.devShell
              config.pre-commit.devShell
            ];
          };
        };
    };
}
