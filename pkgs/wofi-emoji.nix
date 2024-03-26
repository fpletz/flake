{
  fetchurl,
  runCommandLocal,
  writers,
  jq,
  wofi,
  wtype,
  wl-clipboard,
  ...
}:
let
  emoji-data = runCommandLocal "emoji-data" { } ''
    cat ${
      fetchurl {
        url = "https://raw.githubusercontent.com/muan/emojilib/v3.0.11/dist/emoji-en-US.json";
        hash = "sha256-WHqCSNgDzc6ZASdVrwPvsU4MtBcYLKDp2D2Hykrq1sI=";
      }
    } \
      | ${jq}/bin/jq --raw-output '. | to_entries | .[] | .key + " " + (.value | join(" ") | sub("_"; " "; "g"))' > $out
  '';
in
writers.writeBashBin "wofi-emoji" ''
  set -euo pipefail
  emoji=$(${wofi}/bin/wofi -p "emoji" --show dmenu -i < ${emoji-data} | cut -d ' ' -f 1 | tr -d '\n')
  ${wtype}/bin/wtype "''${emoji}" || ${wl-clipboard}/bin/wl-copy "''${emoji}"
''
