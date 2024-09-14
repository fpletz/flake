{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.bpletza.hardware.thinkpad.a485 = lib.mkEnableOption "Thinkpad A485";

  config = lib.mkIf config.bpletza.hardware.thinkpad.a485 {
    bpletza.hardware.cpu.amd = true;

    boot = {
      initrd.availableKernelModules = [
        "nvme"
        "ehci_pci"
        "xhci_pci"
        "ahci"
        "usb_storage"
        "sd_mod"
        "rtsx_pci_sdmmc"
      ];
      extraModulePackages = with config.boot.kernelPackages; [
        acpi_call
      ];
      extraModprobeConfig = ''
        options thinkpad_acpi fan_control=1
        options psmouse synaptics_intertouch=1
      '';
    };

    networking.wireless = {
      enable = true;
      interfaces = [ "wlp2s0" ];
    };

    hardware = {
      firmware = with pkgs; [
        linux-firmware
        alsa-firmware
      ];
      trackpoint = {
        enable = true;
      };
      wirelessRegulatoryDatabase = true;
      amdgpu.initrd.enable = true;
    };

    services.fwupd.enable = true;

    environment.systemPackages = [
      pkgs.radeontop
    ];

    bpletza.workstation = {
      battery = true;
      waybar.wiredInterface = "enp5s0";
      i3status-rs.blocks.temperatures = [
        {
          block = "temperature";
          interval = 2;
          good = 40;
          idle = 60;
          info = 75;
          warning = 80;
          chip = "k10temp-pci-00c3";
          format = "  $icon $max|C ";
        }
      ];
    };
  };
}
