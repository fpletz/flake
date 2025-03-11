{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.bpletza.hardware.gpu.amd = lib.mkEnableOption "AMD GPUs";

  config = lib.mkIf config.bpletza.hardware.gpu.amd {
    hardware.amdgpu = {
      opencl.enable = true;
      amdvlk.enable = true;
      initrd.enable = true;
    };

    nixpkgs.config.rocmSupport = true;

    environment.systemPackages = [
      pkgs.radeontop
      pkgs.rocmPackages.rocminfo
      pkgs.rocmPackages.rocm-smi
    ];
  };
}
