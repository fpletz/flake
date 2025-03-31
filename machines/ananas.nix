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
    device = "UUID=6a981d19-cd1c-4b88-b04b-6c54e04f5e19";
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
