{ lib, config, pkgs, ... }:
{
  options.bpletza.workstation.swaylock = lib.mkOption
    {
      type = lib.types.bool;
      default = config.options.bpletza.workstation.sway;
    };

  config = lib.mkIf config.bpletza.workstation.swaylock {
    programs.swaylock = {
      enable = true;
      settings = {
        font = "Fira Sans";
        color = "000000";
        indicator-radius = 240;
        indicator-thickness = 20;
        key-hl-color = "880033";
        separator-color = "00000000";
        inside-color = "00000088";
        inside-clear-color = "ffd20400";
        inside-caps-lock-color = "009ddc00";
        inside-ver-color = "d9d8d800";
        inside-wrong-color = "ee2e2400";
        ring-color = "231f20D9";
        ring-clear-color = "231f20D9";
        ring-caps-lock-color = "231f20D9";
        ring-ver-color = "231f20D9";
        ring-wrong-color = "231f20D9";
        line-color = "00000000";
        line-clear-color = "ffd204FF";
        line-caps-lock-color = "009ddcFF";
        line-ver-color = "d9d8d8FF";
        line-wrong-color = "ee2e24FF";
        text-clear-color = "ffd20400";
        text-ver-color = "d9d8d800";
        text-wrong-color = "ee2e2400";
        bs-hl-color = "ee2e24FF";
        caps-lock-key-hl-color = "ffd204FF";
        caps-lock-bs-hl-color = "ee2e24FF";
        text-caps-lock-color = "009ddc";
      };
    };

    services.swayidle =
      let
        locker = "loginctl lock-session";
        swaymsg = "${config.wayland.windowManager.sway.package}/bin/swaymsg";
      in
      {
        enable = true;
        timeouts = [
          {
            timeout = 180;
            command = locker;
          }
          {
            timeout = 200;
            command = "${swaymsg} 'output * dpms off'";
            resumeCommand = "${swaymsg} 'output * dpms on'";
          }
        ];
      };

    systemd.user.services.swaylock = {
      Unit = {
        Description = "sway screen locker";
        PartOf = [ "lock.target" ];
        After = [ "lock.target" ];
        OnSuccess = [ "unlock.target" ];
      };
      Service = {
        Type = "forking";
        ExecStart = "${pkgs.swaylock}/bin/swaylock -f";
        Restart = "on-failure";
        RestartSec = 0;
      };
      Install.WantedBy = [ "lock.target" ];
    };
  };
}
