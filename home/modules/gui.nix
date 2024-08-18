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
      name = "phinger-cursors-dark";
      gtk.enable = true;
      x11.enable = true;
    };

    gtk = {
      enable = true;
      font = {
        name = "Inter";
        package = pkgs.inter;
        size = 8;
      };
      theme = {
        name = "Tokyonight-Dark";
        package = pkgs.tokyonight-gtk-theme.override { iconVariants = [ "Dark" ]; };
      };
      iconTheme = {
        name = "Tokyonight-Dark";
        package = config.gtk.theme.package;
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
      platformTheme.name = "gtk";
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

    programs.zathura = {
      enable = true;
      extraConfig = builtins.readFile "${pkgs.vimPlugins.tokyonight-nvim}/extras/zathura/tokyonight_night.zathurarc";
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

    services.easyeffects.enable = true;

    programs.mpv = {
      enable = true;
      config = {
        ytdl-format = "bestvideo[vcodec^=vp9][height<=?1080]+bestaudio[acodec=opus]/bestvideo[height<=?1080]+bestaudio/best";
        vo = "gpu";
        gpu-context = "auto";
        hwdec = "auto-safe";
      };
    };

    services.gammastep = {
      enable = true;
      latitude = "48";
      longitude = "11";
      temperature = {
        day = 5500;
        night = 3800;
      };
      settings = {
        general = {
          fade = 0;
        };
      };
    };

    systemd.user.services.lxpolkit = {
      Unit = {
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Install.WantedBy = [ "graphical-session.target" ];
      Service = {
        ExecStart = "${pkgs.lxsession}/bin/lxpolkit";
        Restart = "always";
      };
    };
  };
}
