{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  systemd,
  libbsd,
  wayland,
  wayland-protocols,
  wayland-scanner,
}:
stdenv.mkDerivation rec {
  pname = "caffeinated";
  version = "0.2.2";

  src = fetchFromGitHub {
    owner = "electrickite";
    repo = "caffeinated";
    rev = version;
    hash = "sha256-c1m8GOeBxrS/e2meHPMBtmIZjrB4ccY+qq+EnzQXm5I=";
  };

  postPatch = ''
    substituteInPlace ./Makefile \
      --replace "--silence-errors" ""
  '';

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [
    systemd
    libbsd
    wayland
    wayland-protocols
    wayland-scanner
  ];
  buildFlags = [ "WAYLAND=1" ];
  installFlags = [
    "DESTDIR=$(out)"
    "PREFIX=/"
  ];

  meta = {
    description = "Prevents the system from entering an idle state";
    homepage = "https://github.com/electrickite/caffeinated";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fpletz ];
    platforms = lib.platforms.linux;
  };
}
