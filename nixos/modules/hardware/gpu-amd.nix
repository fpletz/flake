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
      opencl.enable = false;
      amdvlk.enable = true;
      initrd.enable = true;
      overdrive = {
        enable = true;
        ppfeaturemask = "0xffffffff";
      };
    };

    nixpkgs.config.rocmSupport = true;

    environment.systemPackages = [
      pkgs.radeontop
      pkgs.rocmPackages.rocminfo
      pkgs.rocmPackages.rocm-smi
    ];
  };
}
