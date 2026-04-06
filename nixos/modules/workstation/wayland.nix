{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.bpletza.workstation;
in
{
  config = lib.mkIf cfg.enable {
    services.greetd = {
      enable = true;
      settings.default_session.command = "${lib.getExe pkgs.tuigreet} --remember-session";
      useTextGreeter = true;
    };

    programs.niri = {
      enable = true;
      useNautilus = false;
    };

    systemd.user.services.noctalia-shell = {
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      environment.PATH = lib.mkForce null;
      serviceConfig = {
        ExecStart = lib.getExe pkgs.noctalia-shell;
        Slice = "session.slice";
        Restart = "on-failure";
      };
    };

    qt = {
      enable = true;
      platformTheme = "qt5ct";
      # style = "gtk2";
    };

    environment.systemPackages = [
      pkgs.xwayland-satellite
      pkgs.noctalia-shell
      pkgs.evtest
    ];
  };
}
