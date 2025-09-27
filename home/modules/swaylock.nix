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
  options.bpletza.workstation.swaylock = lib.mkOption {
    type = lib.types.bool;
    default = config.bpletza.workstation.wayland;
  };

  config = lib.mkIf config.bpletza.workstation.swaylock {
    services.systemd-lock-handler.enable = true;

    programs.swaylock.enable = true;

    systemd.user.services.swayidle.Install.WantedBy = [
      "niri.service"
      "sway-session.target"
    ];

    services.swayidle =
      let
        niri = lib.getExe pkgs.niri;
        swaymsg = lib.getExe' pkgs.sway "swaymsg";
      in
      {
        enable = true;
        systemdTarget = "wayland-session@sway.target";
        timeouts = [
          {
            timeout = 120;
            command = "${lib.getExe' systemdPackage "loginctl"} lock-session";
          }
          {
            timeout = 180;
            command = ''[ -n "$SWAYSOCK" ] && ${swaymsg} "output * dpms off" || ${niri} msg action power-off-monitors'';
            resumeCommand = ''[ -n "$SWAYSOCK" ] && ${swaymsg} "output * dpms on" || ${niri} power-on-monitors'';
          }
        ];
      };

    systemd.user.services.swaylock = {
      Unit = {
        Description = "wayland screen locker";
        PartOf = [ "lock.target" ];
        After = [ "lock.target" ];
        OnSuccess = [ "unlock.target" ];
        ConditionEnvironment = [ "WAYLAND_DISPLAY" ];
      };
      Service = {
        Type = "forking";
        ExecStart = "${lib.getExe pkgs.swaylock} -f";
        Restart = "on-failure";
        RestartSec = 0;
      };
      Install.WantedBy = [ "lock.target" ];
    };
  };
}
