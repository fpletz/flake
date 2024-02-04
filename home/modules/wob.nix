{ pkgs, config, ... }:
{
  xdg.configFile."wob/wob.ini".text = with config.colorScheme.palette; ''
    timeout = 750
    background_color = ${base00}EE
    bar_color = ${base08}
    border_color = ${base08}
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
      PartOf = [ "sway-session.target" ];
      After = [ "sway-session.target" ];
      ConditionEnvironment = [ "WAYLAND_DISPLAY" ];
    };
    Socket = {
      ListenFIFO = "%t/wob.sock";
      SocketMode = "0600";
      RemoveOnStop = "yes";
      FlushPending = "yes";
    };
    Install = {
      WantedBy = [ "sockets.target" ];
    };
  };
}
