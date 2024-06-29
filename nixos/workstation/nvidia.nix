{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.bpletza.workstation;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.bpletza.workstation.nvidia = mkEnableOption "nvidia support";

  config = mkIf cfg.nvidia {
    nixpkgs.config = {
      allowUnfree = true;
      cudaSupport = true;
    };
    services.xserver.videoDrivers = [ "nvidia" ];
    boot.kernelParams = [ "nvidia-drm.fbdev=1" ];
    hardware = {
      nvidia = {
        package = config.boot.kernelPackages.nvidiaPackages.beta;
        modesetting.enable = true;
        forceFullCompositionPipeline = true;
        open = true;
      };
      graphics.extraPackages = [ pkgs.nvidia-vaapi-driver ];
    };
  };
}
