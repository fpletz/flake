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
    nixpkgs.config.allowUnfree = true;
    services.xserver.videoDrivers = [ "nvidia" ];
    hardware.nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.beta;
      modesetting.enable = true;
      forceFullCompositionPipeline = true;
    };
    hardware.opengl.extraPackages = [ pkgs.nvidia-vaapi-driver ];
    nixpkgs.config.cudaSupport = true;
  };
}
