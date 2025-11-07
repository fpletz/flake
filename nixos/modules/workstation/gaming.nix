{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.bpletza.workstation;
in
{
  options = {
    bpletza.workstation.gaming = lib.mkEnableOption "gaming support";
  };

  config = lib.mkIf (cfg.enable && cfg.gaming) {
    hardware.graphics.enable32Bit = pkgs.stdenv.hostPlatform.isx86_64 && cfg.gaming;
    services.pipewire.alsa.support32Bit = pkgs.stdenv.hostPlatform.isx86_64 && cfg.gaming;

    environment.systemPackages = [
      pkgs.heroic
    ];

    programs.steam = {
      enable = cfg.gaming;
      gamescopeSession.enable = cfg.gaming;
    };
  };
}
