{ pkgs, ... }:
{
  home.pointerCursor = {
    package = pkgs.phinger-cursors;
    name = "phinger-cursors";
    gtk.enable = true;
    x11.enable = true;
  };

  gtk = {
    enable = true;
    font = {
      name = "Fira Sans 8";
      package = pkgs.fira;
    };
    theme = {
      name = "Tokyonight-Dark-B";
      package = pkgs.tokyo-night-gtk-variants.full;
    };
    iconTheme = {
      name = "Tokyonight-Dark";
      package = pkgs.tokyo-night-gtk-variants.icons.dark;
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
}
