{ pkgs, ... }:
{
  programs.dircolors = {
    enable = true;
    settings = builtins.fromJSON (builtins.readFile (pkgs.runCommand "dircolors.json" { } ''
      ${pkgs.vivid}/bin/vivid generate tokyonight-night | \
        ${pkgs.python3}/bin/python3 -c 'import sys, json; print(json.dumps(dict([s.split("=") for s in sys.stdin.read().strip().split(":")])))' \
        > $out
    ''));
  };

  nixpkgs.overlays = [
    (final: prev: {
      # vivid master with working tokyonight theme
      vivid = prev.vivid.overrideAttrs (attrs: rec {
        version = "unstable-2024-01-16";
        src = attrs.src.override (_: {
          rev = "2ddbc2f344b30451a995beb6489b583ca23cac4f";
          hash = "sha256-LLjLGCuIaH1idKY7lu8HNW3lasio9nkMi0E0rOxUmoY=";
        });
        patches = [
          (final.fetchpatch {
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
    })
  ];
}
