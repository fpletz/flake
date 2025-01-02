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

  boot.loader.systemd-boot = {
    enable = true;
  };

  bpletza.hardware.thinkpad.a485 = true;
  bpletza.workstation.enable = true;
}
