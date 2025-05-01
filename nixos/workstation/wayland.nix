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
      settings.default_session.command = lib.getExe pkgs.greetd.tuigreet;
    };

    xdg.portal.config = {
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

    security = {
      soteria.enable = true;
      pam.services = {
        swaylock = { };
      };
    };

    programs.niri.enable = true;
    services.gnome.gnome-keyring.enable = false; # set by niri NixOS module

    systemd.user.services.xwayland-satellite = {
      wantedBy = [ "niri.service" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        ExecStart = lib.getExe pkgs.xwayland-satellite;
      };
    };

    qt = {
      enable = true;
      platformTheme = "gtk2";
      style = "gtk2";
    };
  };
}
