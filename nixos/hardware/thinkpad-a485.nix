{ config, lib, pkgs, ... }:
{
  options.bpletza.hardware.thinkpad.a485 = lib.mkEnableOption "Thinkpad A485";

  config = lib.mkIf config.bpletza.hardware.thinkpad.a485 {
    bpletza.hardware.cpu.amd = true;

    boot = {
      initrd.availableKernelModules = [ "nvme" "ehci_pci" "xhci_pci" "ahci" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
      extraModulePackages = with config.boot.kernelPackages; [ acpi_call ryzen_smu ];
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
      firmware = with pkgs; [ linux-firmware alsa-firmware ];
      trackpoint = {
        enable = true;
      };
      wirelessRegulatoryDatabase = true;
    };

    services.thinkfan = {
      enable = true;
      extraArgs = [ "-s" "3" "-b" "2.0" ];
      levels = [
        [ 0 0 35 ]
        [ 1 30 40 ]
        [ 2 35 60 ]
        [ 3 55 60 ]
        [ 4 65 75 ]
        [ 5 72 78 ]
        [ 6 75 80 ]
        [ 7 78 85 ]
        [ "level full-speed" 90 200 ]
      ];
    };

    services.fwupd.enable = true;

    bpletza.workstation = {
      battery = true;
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
