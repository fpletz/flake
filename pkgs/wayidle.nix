{
  lib,
  rustPlatform,
  fetchFromSourcehut,
}:
rustPlatform.buildRustPackage rec {
  pname = "wayidle";
  version = "0.1.1";

  src = fetchFromSourcehut {
    owner = "~whynothugo";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-6wULrwGnXLdrX/THanJThbykKjNKpGukw9dj0jX0/dM=";
  };

  cargoHash = "sha256-zF2s3XSXnN7jVtv/0axzHiIJd/cb6wMYAOQILXp1U5U=";

  meta = with lib; {
    description = "Wait for wayland compositor idle timeouts";
    homepage = "https://git.sr.ht/~whynothugo/wayidle";
    license = with licenses; [ isc ];
    maintainers = with lib; [ fpletz ];
    platforms = platforms.linux;
  };
}
