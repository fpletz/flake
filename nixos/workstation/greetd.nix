{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.bpletza.workstation;
in
{
  config = lib.mkIf cfg.enable {
    services.greetd = {
      enable = true;
      settings.default_session.command =
        let
          swayConfig = pkgs.writeText "greetd-sway-config" ''
            exec "${lib.getExe config.programs.regreet.package}; swaymsg exit"
            bindsym Mod4+shift+e exec swaynag \
              -t warning \
              -m 'What do you want to do?' \
              -b 'Poweroff' 'systemctl poweroff' \
              -b 'Reboot' 'systemctl reboot'
          '';
        in
        "${pkgs.dbus}/bin/dbus-run-session ${lib.getExe pkgs.sway} --config ${swayConfig}";
    };

    programs.regreet = {
      enable = true;
      cursorTheme = {
        name = "phinger-cursors-dark";
        package = pkgs.phinger-cursors;
      };
      font = {
        name = "Departure Mono";
        package = pkgs.departure-mono;
        size = 16;
      };
      theme = {
        name = "Tokyonight-Dark";
        package = pkgs.tokyonight-gtk-theme.override {
          iconVariants = [ "Dark" ];
        };
      };
      iconTheme = {
        name = config.programs.regreet.theme.name;
        package = config.programs.regreet.theme.package;
      };
      settings = {
        background = {
          path = ../../static/wallpapers/by_upload1_2560.jpg;
          fit = "Cover";
        };
        appearance.greeting_msg = "EHLO";
        GTK.application_prefer_dark_theme = true;
      };
    };

    programs.sway = {
      enable = true;
      extraPackages = [ ];
      wrapperFeatures.gtk = true;
    };
  };
}
