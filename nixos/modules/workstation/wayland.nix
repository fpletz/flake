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

    programs.niri = {
      enable = true;
      useNautilus = false;
    };

    systemd.user.services.noctalia-shell = {
      wantedBy = [ "niri.service" ];
      bindsTo = [ "niri.service" ];
      partOf = [ "niri.service" ];
      after = [ "niri.service" ];
      path = [
        pkgs.bashNonInteractive
        pkgs.curl
        pkgs.fontconfig
        pkgs.procps
        pkgs.coreutils
      ];
      serviceConfig = {
        ExecStart = lib.getExe pkgs.noctalia-shell;
        Slice = "session.slice";
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
    ];
  };
}
