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
        url = "https://raw.githubusercontent.com/muan/emojilib/v4.0.2/dist/emoji-en-US.json";
        hash = "sha256-PjrIs6OhLkFIV++80GwcdPtFeEjlZezeM3LP+Ca/wDI=";
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
