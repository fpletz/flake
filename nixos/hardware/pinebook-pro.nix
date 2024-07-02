{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.bpletza.hardware.pinebook-pro = lib.mkEnableOption "Pinebook Pro";

  config = lib.mkIf config.bpletza.hardware.pinebook-pro {
    # tow-boot has extlinux support
    boot.loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
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

    hardware.enableRedistributableFirmware = true;

    # The default powersave makes the wireless connection unusable.
    networking.networkmanager.wifi.powersave = lib.mkDefault false;

    # Fixes some opengl apps like alacritty
    environment.sessionVariables = {
      PAN_MESA_DEBUG = "gl3";
    };

    # For bluetooth
    hardware.firmware = [ pkgs.ap6256-firmware ];

    powerManagement = {
      cpuFreqGovernor = "performance";
      scsiLinkPolicy = "min_power";
    };

    networking.wireless = {
      enable = true;
      interfaces = [ "wlan0" ];
    };

    bpletza.workstation = {
      battery = true;
      i3status-rs.blocks.temperatures = [
        {
          block = "temperature";
          interval = 5;
          good = 30;
          idle = 50;
          info = 60;
          warning = 70;
          chip = "cpu_thermal-virtual-0";
          format = "  $icon $max|C ";
        }
      ];
    };
  };
}
