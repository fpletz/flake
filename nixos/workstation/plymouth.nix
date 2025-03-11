{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.bpletza.workstation.plymouth = lib.mkEnableOption "bootsplash" // {
    default = config.bpletza.workstation.enable;
  };

  config = lib.mkIf config.bpletza.workstation.plymouth {
    boot = {
      plymouth = {
        enable = true;
        theme = "nixos-bgrt";
        themePackages = [ pkgs.nixos-bgrt-plymouth ];
        font = "${pkgs.departure-mono}/share/fonts/otf/DepartureMono-Regular.otf";
      };

      consoleLogLevel = 0;
      initrd.verbose = false;
      kernelParams = [
        "quiet"
        "splash"
        "boot.shell_on_fail"
        "loglevel=3"
        "rd.systemd.show_status=false"
        "rd.udev.log_level=3"
      ];
      loader.timeout = lib.mkForce 0;
    };
  };
}
