{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.bpletza.hardware.thinkpad.p14s-gen5 = lib.mkEnableOption "Thinkpad P14s Gen5";

  config = lib.mkIf config.bpletza.hardware.thinkpad.p14s-gen5 {
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

    environment.systemPackages = [ pkgs.radeontop ];

    bpletza.workstation = {
      battery = true;
    };
  };
}
