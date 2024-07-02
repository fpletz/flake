{
  lib,
  pkgs,
  config,
  ...
}:
{
  options.bpletza.workstation.wob = lib.mkOption {
    type = lib.types.bool;
    default = config.bpletza.workstation.sway;
  };

  config = lib.mkIf config.bpletza.workstation.wob {
    xdg.configFile."wob/wob.ini".text = with config.colorScheme.palette; ''
      timeout = 750
      background_color = ${base00}DD
      bar_color = ${base05}
      border_color = ${base05}
    '';

    systemd.user.services.wob = {
      Unit = {
        Description = "A lightweight overlay volume/backlight/progress/anything bar for Wayland";
        Documentation = "man:wob(1)";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
        ConditionEnvironment = [ "WAYLAND_DISPLAY" ];
      };
      Service = {
        StandardInput = "socket";
        ExecStart = "${pkgs.wob}/bin/wob";
      };
    };

    systemd.user.sockets.wob = {
      Unit = {
        Description = "A lightweight overlay volume/backlight/progress/anything bar for Wayland";
        Documentation = "man:wob(1)";
        PartOf = [ "graphical-session-pre.target" ];
        After = [ "graphical-session-pre.target" ];
        ConditionEnvironment = [ "WAYLAND_DISPLAY" ];
      };
      Socket = {
        ListenFIFO = "%t/wob.sock";
        SocketMode = "0600";
        RemoveOnStop = "yes";
        FlushPending = "yes";
      };
      Install = {
        WantedBy = [ "graphical-session-pre.target" ];
      };
    };
  };
}
