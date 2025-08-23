{ lib, config, ... }:
{
  system.stateVersion = "24.11";

  networking.hostName = "trolovo";

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/AA36-B5EB";
    fsType = "vfat";
    options = [ "umask=0077" ];
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/47b0f3b7-8280-4e1c-b66e-1680f47b0a99";
    fsType = "btrfs";
    options = [
      "subvol=@"
      "discard"
      "noatime"
      "compress=zstd"
    ];
  };

  boot.initrd.luks.devices."luks-b2f94892-2710-4a05-9f30-fe9c201966f7" = {
    device = "/dev/disk/by-uuid/b2f94892-2710-4a05-9f30-fe9c201966f7";
    allowDiscards = true;
  };

  services.beesd.filesystems = {
    root = {
      spec = "LABEL=root";
      hashTableSizeMB = 2048;
      verbosity = "info";
      extraOptions = [
        "--loadavg-target"
        "4.0"
      ];
    };
  };

  boot.loader.systemd-boot = {
    enable = true;
  };

  bpletza.hardware.thinkpad.a485 = true;
  bpletza.secureboot = true;
  bpletza.workstation = {
    enable = true;
    gaming = false;
  };

  powerManagement.cpuFreqGovernor = lib.mkForce "performance";

  sops = {
    secrets = {
      wg-muccc-private = {
        sopsFile = ../secrets/trolovo.yaml;
        owner = "systemd-network";
      };
      wg-muccc-psk = {
        sopsFile = ../secrets/trolovo.yaml;
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
          "10.189.10.2/32"
          "2a01:7e01:e003:8b10::2/128"
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
