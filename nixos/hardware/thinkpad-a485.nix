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
      iwd.enable = true;
      interfaces = [ "wlp2s0" ];
    };

    services.udev.extraRules = ''
      # default wifi card has issues on some access points if power saving is on
      ACTION=="add", SUBSYSTEM=="net", DRIVER=="rtw_8822be", RUN+="${lib.getExe pkgs.iw} dev $name set power_save off"
    '';

    hardware = {
      firmware = with pkgs; [
        linux-firmware
        alsa-firmware
      ];
      trackpoint = {
        enable = true;
      };
      wirelessRegulatoryDatabase = true;
    };

    services.fwupd.enable = true;

    home-manager.sharedModules = [
      {
        programs.waybar.settings.mainBar.temperature = {
          hwmon-path-abs = "/sys/devices/pci0000:00/0000:00:18.3/hwmon";
          input-filename = "temp1_input";
          warning-threshold = 80;
          critical-threshold = 90;
        };
      }
    ];

    bpletza.workstation = {
      battery = true;
      internalDisplay = "eDP-1";
      displayScale = 1.0;
      waybar.wiredInterface = "enp5s0";
      ytdlVideoCodec = "vp9";
    };
  };
}
