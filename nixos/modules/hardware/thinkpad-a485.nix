{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.bpletza.hardware.thinkpad.a485 = lib.mkEnableOption "Thinkpad A485";

  config = lib.mkIf config.bpletza.hardware.thinkpad.a485 {
    bpletza.hardware = {
      cpu.amd = true;
      gpu.amd = true;
    };

    boot = {
      kernelParams = [
        "mitigations=off"
        "tsc=unstable"
        "psmouse.synaptics_intertouch=1"
      ];
      initrd.availableKernelModules = [
        "nvme"
        "ehci_pci"
        "xhci_pci"
        "ahci"
        "usb_storage"
        "sd_mod"
        "rtsx_pci_sdmmc"
      ];
      extraModprobeConfig = ''
        options thinkpad_acpi experimental=1 fan_control=1
      '';
    };

    systemd.network.links."10-dash" = {
      matchConfig.Path = "pci-0000:04:00.0";
      linkConfig.Name = "dash";
    };

    networking.wireless = {
      enable = true;
      interfaces = [ "wlp2s0" ];
    };

    bpletza.hardware.wireless.powerSave.enable = false;

    hardware = {
      firmware = with pkgs; [
        linux-firmware
        alsa-firmware
      ];
      trackpoint = {
        enable = true;
      };
    };

    services.fwupd.enable = true;

    bpletza.workstation = {
      battery = true;
      internalDisplay = "eDP-1";
      displayScale = 1.0;
      ytdlVideoCodec = "vp9";
    };
  };
}
