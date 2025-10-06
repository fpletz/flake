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
      initrd.enable = true;
      overdrive = {
        enable = true;
        ppfeaturemask = "0xffffffff";
      };
    };

    environment.systemPackages = [
      pkgs.radeontop
    ];
  };
}
