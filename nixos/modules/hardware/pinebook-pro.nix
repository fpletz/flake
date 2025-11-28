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

    boot.kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
    boot.kernelParams = [ "console=tty0" ];

    # based on https://github.com/NixOS/nixos-hardware
    boot.initrd.kernelModules = [
      # Rockchip modules
      "rockchip_rga"
      "rockchip_saradc"
      "rockchip_thermal"
      "rockchipdrm"

      # GPU/Display modules
      "governor_performance"
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

    bpletza.hardware.wireless.powerSave.enable = false;

    hardware = {
      firmware = [
        pkgs.linux-firmware
        pkgs.raspberrypiWirelessFirmware
      ];
      enableRedistributableFirmware = false;
    };

    powerManagement = {
      cpuFreqGovernor = lib.mkForce "performance";
      scsiLinkPolicy = "min_power";
    };

    networking = {
      useDHCP = false;
      interfaces.wlan0.useDHCP = true;
      wireless = {
        enable = true;
        interfaces = [ "wlan0" ];
      };
      # The default powersave makes the wireless connection unusable.
      networkmanager.wifi.powersave = false;
    };

    environment.systemPackages = [ pkgs.mmc-utils ];

    nix.settings = {
      keep-outputs = false;
    };

    bpletza.workstation = {
      battery = true;
      ytdlVideoCodec = "avc1";
      internalDisplay = "eDP-1";
      displayScale = 1.0;
    };

    home-manager.sharedModules = [
      {
        services.easyeffects.enable = lib.mkForce false;
        bpletza.workstation.terminal.default = pkgs.alacritty;
      }
    ];
  };
}
