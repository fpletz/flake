{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.bpletza.hardware.pinebook-pro;
in
{
  options.bpletza.hardware.pinebook-pro = {
    enable = lib.mkEnableOption "Pinebook Pro";
    efi = lib.mkEnableOption "Pinebook Pro EFI boot";
  };

  config = lib.mkIf cfg.enable {
    # tow-boot has extlinux and efi support
    boot.loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = !cfg.efi;
      efi.canTouchEfiVariables = false;
      systemd-boot = lib.mkIf cfg.efi {
        enable = true;
        consoleMode = "auto";
        memtest86.enable = lib.mkForce false;
        netbootxyz.enable = lib.mkForce false;
      };
    };

    # based on https://github.com/NixOS/nixos-hardware
    boot.initrd.kernelModules = [
      # Rockchip modules
      "rockchip_rga"
      "rockchip_saradc"
      "rockchip_thermal"
      "rockchipdrm"

      # GPU/Display modules
      "analogix_dp"
      "cec"
      "drm"
      "drm_kms_helper"
      "dw_hdmi"
      "dw_mipi_dsi"
      "gpu_sched"
      "panel_edp"
      "panel_simple"
      "panfrost"
      "pwm_bl"

      # USB / Type-C related modules
      "fusb302"
      "tcpm"
      "typec"

      # PCIe/NVMe
      "nvme"
      "pcie_rockchip_host"
      "phy_rockchip_pcie"

      # Misc. modules
      "cw2015_battery"
      "gpio_charger"
      "rtc_rk808"
    ];

    hardware = {
      firmware = [ pkgs.raspberrypiWirelessFirmware ];
      enableRedistributableFirmware = true;
    };

    powerManagement = {
      cpuFreqGovernor = "schedutil";
      scsiLinkPolicy = "min_power";
    };

    networking = {
      useDHCP = false;
      interfaces.wlan0.useDHCP = true;
      wireless = {
        enable = lib.mkDefault true;
        interfaces = [ "wlan0" ];
      };
      # The default powersave makes the wireless connection unusable.
      networkmanager.wifi.powersave = false;
    };

    bpletza.workstation = {
      battery = true;
      ytdlVideoCodec = "avc1";
    };
  };
}
