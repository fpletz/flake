{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.bpletza.hardware.thinkpad.p14s-gen5 = lib.mkEnableOption "Thinkpad P14s Gen5";

  config = lib.mkIf config.bpletza.hardware.thinkpad.p14s-gen5 {
    boot.kernelParams = [
      # fixes intermittent screen corruption issues
      # https://gitlab.freedesktop.org/drm/amd/-/issues/3388
      "amdgpu.sg_display=0"
      # disable PSR to fix stutters
      # https://gitlab.freedesktop.org/drm/amd/-/issues/3647
      "amdgpu.dcdebugmask=0x10"
      # Embedded controller causes battery drain in s2idle
      "acpi.ec_no_wakeup=1"
    ];

    boot.initrd.availableKernelModules = [
      "nvme"
      "xhci_pci"
      "thunderbolt"
      "usb_storage"
      "sd_mod"
    ];
    hardware.firmware = [ pkgs.firmwareLinuxNonfree ];
    hardware.amdgpu.initrd.enable = true;
    bpletza.hardware.cpu.amd = true;

    services.fwupd.enable = true;
    services.fprintd.enable = true;

    networking.wireless = {
      enable = true;
      interfaces = [ "wlp2s0" ];
    };

    nixpkgs.config.rocmSupport = true;

    environment.systemPackages = [
      pkgs.radeontop
      pkgs.rocmPackages.rocminfo
      pkgs.rocmPackages.rocm-smi
    ];

    bpletza.workstation = {
      battery = true;
    };
  };
}
