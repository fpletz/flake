{
  lib,
  config,
  osConfig,
  ...
}:
{
  options.bpletza.workstation.nvidia = lib.mkOption {
    type = lib.types.bool;
    default = config.bpletza.workstation.wayland && (osConfig.bpletza.workstation.nvidia or false);
  };

  config = lib.mkIf config.bpletza.workstation.nvidia {
    wayland.windowManager.sway = {
      extraOptions = [ "--unsupported-gpu" ];
    };

    home.sessionVariables = {
      WLR_RENDERER = "vulkan";
      WLR_NO_HARDWARE_CURSORS = 1;
      # OpenGL Variables
      GBM_BACKEND = "nvidia-drm";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      # libva stuff
      MOZ_DISABLE_RDD_SANDBOX = 1;
      NVD_BACKEND = "direct";
      LIBVA_DRIVER_NAME = "nvidia";
    };
  };
}
