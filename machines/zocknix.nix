{ pkgs, ... }:
{
  system.stateVersion = "24.11";

  networking.hostName = "zocknix";

  boot.initrd.availableKernelModules = [
    "nvme"
    "usb_storage"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [
    "vfio"
    "vfio_iommu_type1"
    "vfio_pci"
    "xhci_pci"
    "ahci"
    "usbhid"
  ];
  boot.kernelModules = [ "it87" ];
  hardware.firmware = with pkgs; [ firmwareLinuxNonfree ];

  boot.initrd.luks.devices."nvme0crypt" = {
    device = "/dev/disk/by-uuid/da89ead5-c015-4ac8-923b-5b7ca1965740";
    allowDiscards = true;
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/cea70ca4-e6cf-4dfb-82f5-42330f80a305";
    fsType = "btrfs";
    options = [
      "subvol=nixos"
      "compress=zstd"
      "noatime"
    ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/BE6B-A6D5";
    fsType = "vfat";
  };

  fileSystems."/home/fpletz" = {
    device = "/dev/disk/by-uuid/cea70ca4-e6cf-4dfb-82f5-42330f80a305";
    fsType = "btrfs";
    options = [
      "subvol=home-fpletz"
      "compress=zstd"
      "noatime"
    ];
  };

  fileSystems."/mnt/bcachefs" = {
    device = "/dev/disk/by-uuid/e41a16d8-e8c1-4cca-b092-e43d0153082f";
    fsType = "bcachefs";
  };

  swapDevices = [
    {
      device = "/swapfile";
      priority = 1;
    }
  ];

  nix.settings = {
    max-jobs = 16;
    build-cores = 24;
  };

  boot.loader.systemd-boot = {
    enable = true;
    consoleMode = "max";
    extraEntries = {
      "windows.conf" = ''
        title  Windows
        efi     /shellx64.efi
        options -nointerrupt -noconsolein -noconsoleout windows.nsh
      '';
    };
    extraFiles = {
      "shellx64.efi" = "${pkgs.edk2-uefi-shell}/shell.efi";
      "windows.nsh" = pkgs.writeText "windows.nsh" ''
        HD2e65535a1:EFI\Microsoft\Boot\Bootmgfw.efi
      '';
    };
  };
  boot.loader.efi.canTouchEfiVariables = true;
  services.fwupd.enable = true;

  bpletza.hardware.cpu.amd = true;

  home-manager.sharedModules = [
    {
      programs.waybar.settings.mainBar.temperature = {
        hwmon-path-abs = "/sys/devices/pci0000:00/0000:00:18.3/hwmon";
        input-filename = "temp1_input";
      };
    }
  ];

  bpletza.workstation = {
    enable = true;
    libvirt = true;
    nvidia = true;
    gaming = true;
    ai = true;
    ytdlVideoCodec = "av01";
    ytdlMaxRes = 1440;
  };
}
