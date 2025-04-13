{
  lib,
  config,
  ...
}:
let
  cfg = config.bpletza.workstation;
in
{
  config = lib.mkIf cfg.enable {
    services.desktopManager.cosmic.enable = true;
    services.displayManager.cosmic-greeter.enable = true;
    networking.networkmanager.enable = lib.mkForce false;

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
  };
}
