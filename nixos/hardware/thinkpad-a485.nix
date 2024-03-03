{ config, lib, pkgs, ... }:
{
  options.bpletza.hardware.thinkpad.a485 = lib.mkEnableOption "Thinkpad A485";

  config = lib.mkIf config.bpletza.hardware.thinkpad.a485 {
    boot = {
      initrd.availableKernelModules = [ "nvme" "ehci_pci" "xhci_pci" "ahci" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
      kernelModules = [ "kvm-amd" ];
      kernelParams = [ "amd_pstate=active" ];
      extraModulePackages = with config.boot.kernelPackages; [ acpi_call ryzen_smu ];
      extraModprobeConfig = ''
        options thinkpad_acpi fan_control=1
        options psmouse synaptics_intertouch=1
      '';
    };
    services.fwupd.enable = true;
    networking.wireless = {
      enable = true;
      interfaces = [ "wlp2s0" ];
    };
    hardware = {
      cpu.amd.updateMicrocode = true;
      firmware = with pkgs; [ linux-firmware alsa-firmware ];
      trackpoint = {
        enable = true;
      };
      wirelessRegulatoryDatabase = true;
    };
    powerManagement.cpuFreqGovernor = "schedutil";

    services.power-profiles-daemon.enable = true;

    services.thinkfan = {
      enable = true;
      extraArgs = [ "-s" "3" "-b" "2.0" ];
      levels = [
        [ 0 0 35 ]
        [ 1 30 40 ]
        [ 2 35 40 ]
        [ 3 40 50 ]
        [ 4 50 60 ]
        [ 5 60 70 ]
        [ 6 65 75 ]
        [ 7 65 90 ]
        [ "level full-speed" 85 200 ]
      ];
    };

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
