{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.programs.spotify-unfree;
in
{
  options.programs.spotify-unfree = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = config.bpletza.workstation.gui && pkgs.stdenv.hostPlatform.isx86_64;
      description = "Unfree Spotify Client";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.spicetify =
      let
        spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
      in
      {
        enable = true;
        enabledExtensions = with spicePkgs.extensions; [
          adblock
          hidePodcasts
          shuffle
          listPlaylistsWithSong
          playlistIntersection
          playingSource
          addToQueueTop
          history
          fullAlbumDate
          playNext
          betterGenres
          history
        ];
        theme = spicePkgs.themes.comfy;
        colorScheme = "catppuccin-mocha";
      };
  };
}
