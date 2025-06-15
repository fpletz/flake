{
  networking.hostName = "fpine";

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/c98b41d0-ac82-45e7-b9ce-acfc92a13a55";
    fsType = "f2fs";
    options = [
      "noatime"
    ];
  };

  boot.initrd.luks.devices."fpine-root" = {
    device = "/dev/disk/by-uuid/bffaf98f-8cf6-4f0d-b578-d51c1188743a";
    allowDiscards = true;
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/9469-AD0A";
    fsType = "vfat";
    options = [
      "fmask=0022"
      "dmask=0022"
    ];
  };

  bpletza.hardware.pinebook-pro = {
    enable = true;
    efi = true;
  };
  bpletza.workstation.enable = true;
}
