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
    nixpkgs = {
      permittedUnfreePackages = [
        "nvidia-x11"
        "nvidia-settings"
        "cuda_cudart"
        "cuda_cccl"
        "libnpp"
        "libcublas"
        "libcufft"
        "cuda_nvcc"
      ];
      config = {
        cudaSupport = true;
      };
    };
    services.xserver.videoDrivers = [ "nvidia" ];
    boot = {
      kernelParams = [ "nvidia-drm.fbdev=1" ];
      kernelModules = [
        # Required by CUDA, isn't loaded automatically when using open modules
        "nvidia_uvm"
      ];
    };
    hardware = {
      nvidia = {
        package = config.boot.kernelPackages.nvidiaPackages.beta;
        modesetting.enable = true;
        forceFullCompositionPipeline = true;
        open = true;
      };
      graphics.extraPackages = [
        pkgs.libva-vdpau-driver
        pkgs.nvidia-vaapi-driver
      ];
    };
  };
}
