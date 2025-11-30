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
  boot.extraModulePackages = [ config.boot.kernelPackages.it87 ];
  hardware.firmware = with pkgs; [ linux-firmware ];

  environment.etc = {
    "sensors.d/gigabyte-x590-pro.conf".text = ''
      chip "acpitz-acpi-0"
          # These will provably never function (analysis of disassembled ACPI tables shows that for some reason,
          # on my mobo these are hardcoded to always return 290 Kelvins)
          ignore temp1
          ignore temp2

      chip "it8688-isa-0a40"
          # Beware, this sometimes reports unrealistic values (300-400mV). Could it be due to C-states?
          label in0 "CPU VCORE"

          label in1 "+3.3V"
          label in2 "+12V"
          label in3 "+5V"
          label in4 "CPU VCORE SoC"
          label in5 "CPU VDDP"
          label in6 "DRAM CH(A/B)"
          label in7 "3VSB"
          label in8 "VBAT"

          compute in1 @ * (33/20), @ / (33/20)
          compute in2 @ * (120/20), @ / (120/20)
          compute in3 @ * (50/20), @ / (50/20)

          label fan1 "CPU_FAN"
          label fan2 "SYS_FAN1"
          label fan3 "SYS_FAN2"
          label fan4 "PCH_FAN"  # AKA SYS_FAN3
          label fan5 "CPU_OPT"

          label temp1 "System1"
          label temp2 "EC_TEMP1"  # Will show -55C if open circuit (no thermistor plugged in)
          ignore temp2  # Reenable if thermistor installed (removing it so it doesn't confuse UIs)
          label temp3 "CPU"
          label temp4 "PCIEX16"
          label temp5 "VRM MOS"
          label temp6 "PCH"

          ignore intrusion0

      chip "it8792-isa-0a60"
          label in1 "DDRVTT CH(A/B)"
          label in2 "Chipset Core"
          label in4 "CPU VDD 18"
          label in5 "PM_CLDO12"

          # Unclear what these are
          ignore in0
          ignore in6

          # Likely redundant with those on the IT8688
          ignore in3
          ignore in7
          ignore in8

          label fan1 "SYS_FAN5_PUMP"
          label fan2 "SYS_FAN6_PUMP"
          label fan3 "SYS_FAN4"

          label temp1 "PCIEX8"
          label temp2 "EC_TEMP2"  # Will show -55C if open circuit (no thermistor plugged in)
          ignore temp2  # Reenable if thermistor installed (removing it so it doesn't confuse UIs)
          label temp3 "System2"

          ignore intrusion0
    '';
  };

  services.hardware.openrgb = {
    enable = true;
    motherboard = "amd";
    startupProfile = "default.orp";
  };

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
