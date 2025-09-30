{
  stdenv,
  lib,
  appimageTools,
  fetchurl,
  makeDesktopItem,
  copyDesktopItems,
}:
let
  pname = "helium-browser";
  version = "0.4.12.1";

  architectures = {
    "x86_64-linux" = {
      arch = "x86_64";
      hash = "sha256-Za1erduSuuWvfrV/oggSz3ttj79SVV5g1CdXtlWfanU=";
    };
    "aarch64-linux" = {
      arch = "arm64";
      hash = "sha256-lBXz6qwwFmJekHUXerm2QOKR4dP2dDC7r55tXBsIw1w=";
    };
  };

  src =
    let
      inherit (architectures.${stdenv.hostPlatform.system}) arch hash;
    in
    fetchurl {
      url = "https://github.com/imputnet/helium-linux/releases/download/${version}/helium-${version}-${arch}.AppImage";
      inherit hash;
    };
in
appimageTools.wrapType2 {
  inherit pname version src;
  nativeBuildInputs = [ copyDesktopItems ];
  desktopItems = [
    (makeDesktopItem {

    })
  ];
  meta = {
    platforms = lib.attrNames architectures;
  };
}
