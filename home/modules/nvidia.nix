{
  lib,
  config,
  osConfig,
  ...
}:
{
  options.bpletza.workstation.nvidia = lib.mkOption {
    type = lib.types.bool;
    default = config.bpletza.workstation.sway && (osConfig.bpletza.workstation.nvidia or false);
  };

  config = lib.mkIf config.bpletza.workstation.nvidia {
    wayland.windowManager.sway = {
      extraOptions = [ "--unsupported-gpu" ];
    };

    home.sessionVariables = {
      # Hardware cursors not yet working on wlroots
      WLR_NO_HARDWARE_CURSORS = 1;
      WLR_RENDERER = "vulkan";
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
