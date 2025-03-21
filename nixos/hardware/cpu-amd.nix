{ config, lib, ... }:
{
  options.bpletza.hardware.cpu.amd = lib.mkEnableOption "AMD CPUs";

  config = lib.mkIf config.bpletza.hardware.cpu.amd {
    boot = {
      kernelModules = [ "kvm-amd" ];
      kernelParams = [ "amd_pstate=active" ];
    };

    hardware.cpu.amd.updateMicrocode = true;

    services.power-profiles-daemon.enable = true;
  };
}
