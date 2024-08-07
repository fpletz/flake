{
  lib,
  config,
  osConfig,
  pkgs,
  ...
}:
let
  systemdPackage = osConfig.systemd.package or pkgs.systemd;
in
{
  options.bpletza.workstation.waylock = lib.mkOption {
    type = lib.types.bool;
    default = config.bpletza.workstation.sway;
  };

  config = lib.mkIf config.bpletza.workstation.waylock {
    services.systemd-lock-handler.enable = true;

    systemd.user.services.wayidle = {
      Unit = {
        Description = "wayland idle detector";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
        ConditionEnvironment = [ "WAYLAND_DISPLAY" ];
      };
      Service = {
        ExecStart = "${pkgs.wayidle}/bin/wayidle -t 180 ${systemdPackage}/bin/loginctl lock-session";
        Restart = "always";
        RestartSec = 0;
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };

    services.swayidle =
      let
        swaymsg = "${config.wayland.windowManager.sway.package}/bin/swaymsg";
      in
      {
        enable = true;
        timeouts = [
          {
            timeout = 200;
            command = "${swaymsg} 'output * dpms off'";
            resumeCommand = "${swaymsg} 'output * dpms on'";
          }
        ];
      };

    systemd.user.services.waylock = {
      Unit = {
        Description = "wayland screen locker";
        PartOf = [ "lock.target" ];
        After = [ "lock.target" ];
        OnSuccess = [ "unlock.target" ];
        ConditionEnvironment = [ "WAYLAND_DISPLAY" ];
      };
      Service = {
        Type = "forking";
        ExecStart = "${pkgs.waylock}/bin/waylock -fork-on-lock";
        Restart = "on-failure";
        RestartSec = 0;
      };
      Install.WantedBy = [ "lock.target" ];
    };
  };
}
