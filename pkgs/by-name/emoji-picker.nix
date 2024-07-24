{
  lib,
  fetchurl,
  runCommandLocal,
  writers,
  fuzzel,
  jq,
  wtype,
  wl-clipboard,
  ...
}:
let
  emoji-data = runCommandLocal "emoji-data" { } ''
    cat ${
      fetchurl {
        url = "https://raw.githubusercontent.com/muan/emojilib/v3.0.12/dist/emoji-en-US.json";
        hash = "sha256-q6YcO8Fd1RuQe9rgY25Ga+cD7OULdDRC8Ck4or9h9oQ=";
      }
    } \
      | ${jq}/bin/jq --raw-output '. | to_entries | .[] | .key + " " + (.value | join(" ") | sub("_"; " "; "g"))' > $out
  '';
in
writers.writeBashBin "emoji-picker" ''
  set -euo pipefail
  emoji=$(${lib.getExe fuzzel} -d < ${emoji-data} | cut -d ' ' -f 1 | tr -d '\n')
  ${wtype}/bin/wtype "''${emoji}" || ${wl-clipboard}/bin/wl-copy "''${emoji}"
''
