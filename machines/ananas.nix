{ pkgs, ... }:
{
  networking.hostName = "ananas";
  networking.useDHCP = true;

  boot.initrd.availableKernelModules = [
    "ehci_pci"
    "ahci"
    "uhci_hcd"
    "xhci_pci"
    "usb_storage"
    "usbhid"
    "sd_mod"
  ];
  boot.kernelModules = [ "kvm-intel" ];

  powerManagement.cpuFreqGovernor = "schedutil";

  fileSystems."/" = {
    device = "UUID=117c6766-f084-4c17-9df1-8d377be90234";
    fsType = "bcachefs";
    options = [
      "noatime"
    ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-id/usb-HP_iLO_Internal_SD-CARD_000002660A01-0:0-part2";
    fsType = "vfat";
    options = [ "umask=0077" ];
  };

  boot.loader.grub = {
    enable = true;
    efiSupport = false;
    devices = [
      "/dev/disk/by-id/usb-HP_iLO_Internal_SD-CARD_000002660A01-0:0"
    ];
  };

  services.journald.extraConfig = ''
    Storage=volatile
  '';

  environment.systemPackages = with pkgs; [ ipmitool ];

  services.prometheus.exporters.ipmi = {
    enable = true;
  };
}
