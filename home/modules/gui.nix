{
  lib,
  config,
  pkgs,
  osConfig,
  ...
}:
let
  cfg = config.bpletza.workstation;
in
{
  options.bpletza.workstation = {
    gui = lib.mkOption {
      type = lib.types.bool;
      default = config.bpletza.workstation.wayland;
    };
    ytdlVideoCodec = lib.mkOption {
      type = lib.types.str;
      default = osConfig.bpletza.workstation.ytdlVideoCodec or "vp09";
      description = "youtube-dl video codec";
    };
    ytdlMaxRes = lib.mkOption {
      type = lib.types.int;
      default = osConfig.bpletza.workstation.ytdlMaxRes or 1080;
      description = "youtube-dl maximum resolution";
    };
  };

  config = lib.mkIf config.bpletza.workstation.gui {
    stylix.cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 24;
    };

    stylix.icons = {
      enable = true;
      dark = "Papirus-Dark";
      light = "Papirus-Light";
      package = pkgs.papirus-icon-theme;
    };

    stylix.targets = {
      qt.enable = true;
      gtk.enable = true;
      gnome.enable = true;
      kde.enable = true;
      font-packages.enable = true;
      fontconfig.enable = true;
    };

    home.pointerCursor = {
      dotIcons.enable = true;
      gtk.enable = true;
      x11.enable = true;
    };

    dconf.settings = {
      "org/gnome/desktop/interface" = {
        "color-scheme" = "prefer-dark";
      };
      "org/freedesktop/appearance" = {
        "color-scheme" = 1;
      };
    };

    gtk = {
      enable = true;
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
    };

    home.sessionVariables = {
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    };

    home.packages = [
      (
        with config.lib.stylix.colors.withHashtag;
        pkgs.writers.writeBashBin "sm" ''
          ${lib.getExe pkgs.screen-message} --background=${base00} --foreground=${base08}
        ''
      )
      pkgs.libva-utils
      pkgs.twitch-hls-client
    ];

    xdg.configFile."twitch-hls-client/config".text = ''
      quality=best
      player=mpv
      force-https=true
      servers=https://lb-eu.cdn-perfprod.com/live/[channel],https://lb-eu2.cdn-perfprod.com/live/[channel]
    '';

    programs.zathura = {
      enable = true;
      options = {
        scroll-page-aware = true;
      };
    };

    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "application/pdf" = "org.pwmt.zathura.desktop";
      };
    };

    programs.feh = {
      enable = true;
      keybindings = {
        zoom_in = "plus";
        zoom_out = "minus";
      };
    };

    # XXX: broken
    services.easyeffects.enable = false;

    programs.mpv = {
      enable = true;
      config = {
        vo = "gpu-next";
        gpu-context = "auto";
        hwdec = "auto-safe";
        ytdl-format = lib.concatStringsSep "+" [
          "bestvideo[vcodec^=${cfg.ytdlVideoCodec}][height<=?${toString cfg.ytdlMaxRes}]"
          "bestaudio[acodec=opus]/bestvideo[height<=?${toString cfg.ytdlMaxRes}]"
          "bestaudio/best"
        ];
      };
    };
  };
}
