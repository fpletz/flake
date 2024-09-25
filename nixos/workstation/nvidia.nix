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
    boot.kernelParams = [ "nvidia-drm.fbdev=1" ];
    hardware = {
      nvidia = {
        package =
          let
            nvidiaPackages = config.boot.kernelPackages.nvidiaPackages.beta;
          in
          nvidiaPackages.overrideAttrs {
            open = nvidiaPackages.open.overrideAttrs {
              patches = [
                (pkgs.fetchpatch {
                  url = "https://patch-diff.githubusercontent.com/raw/NVIDIA/open-gpu-kernel-modules/pull/692.patch";
                  hash = "sha256-OYw8TsHDpBE5DBzdZCBT45+AiznzO9SfECz5/uXN5Uc=";
                })
              ];
            };
          };
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
