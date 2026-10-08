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

    qt = {
      enable = true;
      platformTheme = "qt5ct";
      # style = "gtk2";
    };

    environment.systemPackages = [
      pkgs.xwayland-satellite
      pkgs.evtest
    ];
  };
}
