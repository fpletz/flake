{ config, pkgs, lib, osConfig, ... }:
let
  cfg = config.programs.spotify-unfree;

  spotify-adblock = pkgs.rustPlatform.buildRustPackage rec {
    name = "spotify-adblock";
    version = "1.0.3";

    src = pkgs.fetchFromGitHub {
      owner = "abba23";
      repo = "spotify-adblock";
      rev = "v${version}";
      hash = "sha256-UzpHAHpQx2MlmBNKm2turjeVmgp5zXKWm3nZbEo0mYE=";
    };

    cargoHash = "sha256-oHfk68mAIcmOenW7jn71Xpt8hWVDtxyInWhVN2rH+kk=";

    postPatch = ''
      substituteInPlace src/lib.rs \
        --replace-fail 'PathBuf::from("/etc/spotify-adblock/config.toml")' \
                       'PathBuf::from("${placeholder "out"}/etc/spotify-adblock/config.toml")'
    '';

    doCheck = false;

    postInstall = ''
      install -vD config.toml $out/etc/spotify-adblock/config.toml
    '';
  };

  package = pkgs.writers.writeBashBin "spotify" ''
    LD_PRELOAD=${spotify-adblock}/lib/libspotifyadblock.so ${lib.getExe pkgs.spotify}
  '';
in
{
  options.programs.spotify-unfree = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = osConfig.bpletza.workstation.spotify or false;
      description = "Unfree Spotify Client";
    };
  };

  config = lib.mkIf cfg.enable {
    nixpkgs.config.allowUnfree = true;
    home.packages = [ package ];
  };
}
