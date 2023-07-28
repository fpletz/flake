{
  description = "fpletz flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
  };

  outputs = { self, nixpkgs, ... }: let
    supportedSystems = [
      "x86_64-linux"
      "i686-linux"
      "aarch64-linux"
      "riscv64-linux"
    ];
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
  in {
    overlays.default = final: prev: {
      wofi-emoji = let
        emoji-data = final.runCommandLocal "emoji-data" {} ''
          cat ${final.fetchurl {
            url = "https://raw.githubusercontent.com/muan/emojilib/v3.0.10/dist/emoji-en-US.json";
            hash = "sha256-UhAB5hVp5vV2d1FjIb2TBd2FJ6OPBbiP31HGAEDQFnA=";
          }} \
            | ${final.jq}/bin/jq --raw-output '. | to_entries | .[] | .key + " " + (.value | join(" ") | sub("_"; " "; "g"))' > $out
        '';
      in final.writers.writeBashBin "wofi-emoji" ''
        set -euo pipefail
        emoji=$(${final.wofi}/bin/wofi -p "emoji" --show dmenu -i < ${emoji-data} | cut -d ' ' -f 1 | tr -d '\n')
        ${final.wtype}/bin/wtype "''${emoji}" || ${final.wl-clipboard}/bin/wl-copy "''${emoji}"
      '';
    };

    packages = forAllSystems (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [self.overlays.default];
      };
    in {
      inherit (pkgs) wofi-emoji;
    });
  };
}
