{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.bpletza.hardware.thinkpad.x230 = lib.mkEnableOption "Thinkpad X230";

  config = lib.mkIf config.bpletza.hardware.thinkpad.x230 {
    boot = {
      initrd = {
        availableKernelModules = [
          "xhci_pci"
          "ehci_pci"
          "ahci"
          "usb_storage"
          "sd_mod"
          "sdhci_pci"
        ];
        kernelModules = [ "i915" ];
      };
      kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
      kernelModules = [ "kvm-intel" ];
      blacklistedKernelModules = [
        "mei_me"
        "mei"
      ];
      extraModprobeConfig = ''
        options thinkpad_acpi experimental=1 fan_control=1
      '';
    };

    networking.wireless = {
      iwd.enable = true;
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
      cpu.intel.updateMicrocode = true;
      graphics.extraPackages = [
        pkgs.intel-vaapi-driver
      ];
    };

    environment.systemPackages = with pkgs; [
      intel-gpu-tools
      coreboot-utils
    ];

    services.power-profiles-daemon.enable = true;

    bpletza.workstation = {
      battery = true;
      waybar.wiredInterface = "eno0";
      ytdlVideoCodec = "avc1";
      internalDisplay = "LVDS-1";
      displayScale = 1.0;
    };
  };
}
