{
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 100;
  };

  boot = {
    tmp.tmpfsSize = "200%";

    kernel.sysctl = {
      "vm.swappiness" = 100;
    };
  };
}
