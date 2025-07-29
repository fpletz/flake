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
      "vm.swappiness" = 100;
      "vm.watermark_boost_factor" = 0;
      "vm.watermark_scale_factor" = 125;
      "vm.page-cluster" = 0;
    };
  };
}
