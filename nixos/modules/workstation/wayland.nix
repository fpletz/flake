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

    programs.uwsm = {
      enable = true;
      waylandCompositors = {
        sway = {
          prettyName = "Sway";
          comment = "Sway (UWSM)";
          binPath = "/run/current-system/sw/bin/sway --unsupported-gpu";
        };
      };
    };

    xdg.portal = {
      config = {
        preferred = {
          default = [
            "gnome"
            "gtk"
          ];
          "org.freedesktop.impl.portal.Access" = "gtk";
          "org.freedesktop.impl.portal.FileChooser" = "gtk";
          "org.freedesktop.impl.portal.Notification" = "gtk";
        };
      };
      wlr = {
        enable = true;
        settings = {
          screencast = {
            max_fps = 30;
            chooser_type = "dmenu";
            chooser_cmd = "${lib.getExe pkgs.fuzzel} -d";
          };
        };
      };
    };

    security = {
      pam.services = {
        swaylock = { };
      };
    };

    programs.sway = {
      enable = true;
      extraPackages = [ ];
    };

    qt = {
      enable = true;
      platformTheme = "gtk2";
      style = "gtk2";
    };

    environment.systemPackages = [ pkgs.xwayland-satellite ];
  };
}
