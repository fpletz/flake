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
        "cuda_nvcc"
        "cuda_nvrtc"
        "cudnn"
        "libnpp"
        "libcublas"
        "libcufft"
        "libcurand"
        "libcusparse"
        "libnvjitlink"
      ];
      config = {
        cudaSupport = true;
      };
    };

    nix.settings = {
      substituters = [
        "https://cache.nixos-cuda.org"
      ];
      trusted-public-keys = [
        "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
      ];
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
        package =
          let
            base = config.boot.kernelPackages.nvidiaPackages.latest;
            cachyos-nvidia-patch = pkgs.fetchpatch {
              url = "https://raw.githubusercontent.com/CachyOS/CachyOS-PKGBUILDS/master/nvidia/nvidia-utils/kernel-6.19.patch";
              sha256 = "sha256-YuJjSUXE6jYSuZySYGnWSNG5sfVei7vvxDcHx3K+IN4=";
            };

            # Patch the appropriate driver based on config.hardware.nvidia.open
            driverAttr = if config.hardware.nvidia.open then "open" else "bin";
          in
          base
          // {
            ${driverAttr} = base.${driverAttr}.overrideAttrs (oldAttrs: {
              patches = (oldAttrs.patches or [ ]) ++ [ cachyos-nvidia-patch ];
            });
          };
        modesetting.enable = true;
        forceFullCompositionPipeline = true;
        open = true;
        videoAcceleration = false;
      };
    };

    services.lact.enable = true;
  };
}
