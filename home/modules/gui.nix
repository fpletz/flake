{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.bpletza.workstation.gui = lib.mkOption {
    type = lib.types.bool;
    default = config.bpletza.workstation.sway;
  };

  config = lib.mkIf config.bpletza.workstation.gui {
    xresources.extraConfig = builtins.readFile "${pkgs.vimPlugins.tokyonight-nvim}/extras/xresources/tokyonight_night.Xresources";

    home.pointerCursor = {
      package = pkgs.phinger-cursors;
      name = "phinger-cursors";
      gtk.enable = true;
      x11.enable = true;
    };

    gtk = {
      enable = true;
      font = {
        name = "Inter Display 8";
        package = pkgs.fira;
      };
      theme = {
        name = "Tokyonight-Dark-BL";
        package = pkgs.tokyonight-gtk-theme-variants.full;
      };
      iconTheme = {
        name = "Tokyonight-Dark";
        package = pkgs.tokyonight-gtk-theme-variants.icons.dark;
      };
      gtk2.extraConfig = ''
        gtk-toolbar-style=GTK_TOOLBAR_BOTH_HORIZ
        gtk-toolbar-icon-size=GTK_ICON_SIZE_SMALL_TOOLBAR
        gtk-button-images=0
        gtk-menu-images=0
        gtk-enable-event-sounds=0
        gtk-enable-input-feedback-sounds=0
        gtk-xft-antialias=1
        gtk-xft-hinting=1
        gtk-xft-hintstyle="hintslight"
        gtk-xft-rgba="rgb"
      '';
      gtk3.extraConfig = {
        gtk-application-prefer-dark-theme = true;
        gtk-menu-images = false;
        gtk-button-images = false;
        gtk-toolbar-style = "GTK_TOOLBAR_BOTH_HORIZ";
        gtk-toolbar-icon-size = "GTK_ICON_SIZE_SMALL_TOOLBAR";
        gtk-enable-event-sounds = false;
        gtk-enable-input-feedback-sounds = false;
        gtk-xft-antialias = 1;
        gtk-xft-hinting = 1;
        gtk-xft-hintstyle = "hintslight";
        gtk-xft-rgba = "rgb";
        gtk-decoration-layout = "menu:close";
      };
      gtk4.extraConfig = {
        gtk-hint-font-metrics = true;
        gtk-application-prefer-dark-theme = true;
        gtk-enable-event-sounds = false;
        gtk-enable-input-feedback-sounds = false;
        gtk-xft-antialias = 1;
        gtk-xft-hinting = 1;
        gtk-xft-hintstyle = "hintslight";
        gtk-xft-rgba = "rgb";
        gtk-decoration-layout = "menu:close";
      };
    };

    qt = {
      enable = true;
      platformTheme = "gtk";
      style.name = "gtk2";
    };

    home.sessionVariables = {
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    };

    home.packages = with config.colorScheme.palette; [
      (pkgs.writers.writeBashBin "sm" ''
        ${lib.getExe pkgs.screen-message} --background=#${base00} --foreground=#${base08}
      '')
    ];
  };
}
