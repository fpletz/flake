{ lib, ... }:
{
  zramSwap = {
    enable = true;
    algorithm = lib.mkDefault "zstd";
    memoryPercent = lib.mkDefault 100;
  };

  boot = {
    tmp.tmpfsSize = "200%";
    kernel.sysctl = {
      "vm.swappiness" = 80;
      "vm.watermark_boost_factor" = 15000;
      "vm.watermark_scale_factor" = 10;
      "vm.page-cluster" = 0;
    };
  };
}
