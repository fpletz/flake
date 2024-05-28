{
  config,
  pkgs,
  lib,
  ...
}:
{
  options.bpletza.workstation.obs = lib.mkOption {
    type = lib.types.bool;
    default = config.bpletza.workstation.sway && pkgs.system == "x86_64-linux";
  };

  config = lib.mkIf config.bpletza.workstation.obs {
    programs.obs-studio = {
      enable = true;
      package = pkgs.obs-studio;
      plugins =
        with pkgs.obs-studio-plugins;
        [
          obs-multi-rtmp
          obs-gstreamer
          wlrobs
          obs-pipewire-audio-capture
          obs-move-transition
          obs-tuna
          obs-text-pthread
          waveform
          obs-vintage-filter
          obs-shaderfilter
        ]
        ++ lib.optionals pkgs.config.allowUnfree [ obs-ndi ];
    };
  };
}
