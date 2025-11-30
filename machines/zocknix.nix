{ config, pkgs, ... }:
{
  system.stateVersion = "25.05";

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
  hardware.firmware = with pkgs; [ linux-firmware ];

  # increase for big builds in tmpfs
  zramSwap.memoryPercent = 200;

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
  bpletza.secureboot = true;

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
    ytdlVideoCodec = "av01";
    ytdlMaxRes = 1440;
  };

  bpletza.twitch.enable = true;

  sops = {
    secrets = {
      wg-muccc-private = {
        sopsFile = ../secrets/zocknix.yaml;
        owner = "systemd-network";
      };
      wg-muccc-psk = {
        sopsFile = ../secrets/zocknix.yaml;
        owner = "systemd-network";
      };
    };
  };

  systemd.network = {
    netdevs."10-muccc" = {
      netdevConfig = {
        Name = "muccc";
        Kind = "wireguard";
        MTUBytes = 1300;
      };
      wireguardConfig = {
        PrivateKeyFile = config.sops.secrets.wg-muccc-private.path;
      };
      wireguardPeers = [
        {
          PublicKey = "GnJFf9goxF/1IjMFTYJhi2ZcV8BREgpfK1+S7Wv/cxY=";
          Endpoint = "stammstrecke.muc.ccc.de:51820";
          PersistentKeepalive = 30;
          PresharedKeyFile = config.sops.secrets.wg-muccc-psk.path;
          AllowedIPs = [
            "10.189.0.0/16"
            "2a01:7e01:e003:8b00::/56"
          ];
        }
      ];
    };
    networks."10-muccc" = {
      matchConfig.Name = "muccc";
      networkConfig = {
        Address = [
          "10.189.10.3/32"
          "2a01:7e01:e003:8b10::3/128"
        ];
        DNS = [ "2a01:7e01:e003:8b00::53" ];
        DNSOverTLS = false;
        Domains = [ "club.muc.ccc.de" ];
      };
      routes = [
        {
          Destination = "10.189.0.0/16";
        }
        {
          Destination = "2a01:7e01:e003:8b00::/56";
        }
      ];
    };
  };
}
