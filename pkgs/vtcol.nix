{ rustPlatform, fetchFromGitLab }:

rustPlatform.buildRustPackage {
  pname = "vtcol";
  version = "0.43.0";

  src = fetchFromGitLab {
    owner = "fpletz";
    repo = "vtcol";
    rev = "af7f863326425f1813f09ccb46cafae70b7bad76";
    hash = "sha256-4jzDV9dUsj0y3sZ1rvuLU1RJ092DkcBfTRSgBOZwsVQ=";
  };

  cargoHash = "sha256-OWFkfgjM34ggknNBFbXNLT+AYtH6kWZrTWlN5GvRIyc=";
  buildFeatures = [ "vtcol-bin" ];

  meta.mainProgram = "vtcol";
}
