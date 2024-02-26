{ pkgs, ... }:
{
  programs.obs-studio = {
    enable = pkgs.system == "x86_64-linux";
    package = pkgs.obs-studio;
    plugins = with pkgs.obs-studio-plugins; [
      obs-multi-rtmp
      obs-gstreamer
      wlrobs
      obs-pipewire-audio-capture
      obs-move-transition
      obs-tuna
      obs-ndi
    ];
  };
}
