{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.bpletza.hardware;
in
{
  imports = lib.filesystem.listFilesRecursive ./hardware;

  options.bpletza.hardware = {
    wireless.powerSave.enable = lib.mkEnableOption "enable wifi power save" // {
      default = true;
    };
  };

  config = {
    services.udev.extraRules = ''
      ACTION=="add", KERNEL=="wl*", SUBSYSTEM=="net", \
        RUN+="${lib.getExe pkgs.iw} dev $name set power_save ${
          if cfg.wireless.powerSave.enable then "on" else "off"
        }"
    '';
  };
}
