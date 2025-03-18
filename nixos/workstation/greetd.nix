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
    };

    programs.regreet = {
      enable = true;
      cursorTheme = {
        name = "phinger-cursors-dark";
        package = pkgs.phinger-cursors;
      };
      font = {
        name = "Recursive Sans Casual Static";
        package = pkgs.recursive;
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

    programs.niri.enable = true;
    services.gnome.gnome-keyring.enable = false; # set by niri NixOS module
  };
}
