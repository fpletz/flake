{ lib, ... }:
{
  networking.hostName = "lolnovo";
  boot.loader.systemd-boot = {
    enable = true;
    consoleMode = "auto";
  };

  bpletza.hardware.thinkpad.x230 = true;
  bpletza.workstation.enable = true;

  home-manager.sharedModules = [
    {
      services.easyeffects.enable = lib.mkForce false;
      services.mopidy.enable = lib.mkForce false;
    }
  ];

  disko.devices = {
    disk.disk1 = {
      device = lib.mkDefault "/dev/disk/by-path/pci-0000:00:1f.2-ata-1";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          esp = {
            name = "ESP";
            size = "512M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };
          luks = {
            size = "100%";
            content = {
              type = "luks";
              name = "lolnovo";
              settings.allowDiscards = true;
              passwordFile = "/tmp/luks";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];
                subvolumes = {
                  "/root" = {
                    mountpoint = "/";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  "/home" = {
                    mountpoint = "/home";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  "/var" = {
                    mountpoint = "/var";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  "/nix" = {
                    mountpoint = "/nix";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
