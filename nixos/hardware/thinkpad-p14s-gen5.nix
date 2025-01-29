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
    boot.extraModprobeConfig = ''
      options thinkpad_acpi fan_control=1
    '';

    hardware.firmware = [
      pkgs.firmwareLinuxNonfree
      pkgs.sof-firmware
    ];
    hardware.amdgpu.initrd.enable = true;
    bpletza.hardware.cpu.amd = true;

    services.fwupd.enable = true;
    services.fprintd.enable = true;

    networking.wireless = {
      enable = true;
      interfaces = [ "wlp2s0" ];
    };

    hardware.trackpoint.enable = true;

    services.udev.extraRules = ''
      # Disable wakeup via touchpad events
      KERNEL=="i2c-SYNA8018:00", SUBSYSTEM=="i2c", ATTR{power/wakeup}="disabled"
    '';

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
