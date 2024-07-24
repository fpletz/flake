{
  config,
  osConfig,
  lib,
  pkgs,
  ...
}:
{
  options.bpletza.workstation.sway = lib.mkOption {
    type = lib.types.bool;
    default = osConfig.bpletza.workstation.enable or false;
  };

  config = lib.mkIf config.bpletza.workstation.sway {
    services.mako =
      {
        enable = true;
        font = "Inter 10";
        iconPath = "${config.gtk.iconTheme.package}/share/icons/${config.gtk.iconTheme.name}";
        defaultTimeout = 5000;
      }
      // (with config.colorScheme.palette; {
        backgroundColor = "#${base00}";
        textColor = "#${base05}";
        borderColor = "#${base0D}";
        extraConfig = ''
          [urgency=low]
          background-color=#${base00}
          text-color=#${base0A}
          border-color=#${base0D}

          [urgency=high]
          background-color=#${base00}
          text-color=#${base08}
          border-color=#${base0D}
        '';
      });

    programs.fuzzel = {
      enable = true;
      settings = {
        main = {
          terminal = config.bpletza.workstation.terminal.default;
          dpi-aware = true;
          font = "Inter:size=8";
          icon-theme = config.gtk.iconTheme.name;
        };
        colors = with config.colorScheme.palette; {
          background = "${base00}dd";
          text = "${base05}ff";
          match = "${base08}ff";
          selection = "${base02}dd";
          selection-text = "${base05}ff";
          selection-match = "${base08}ff";
          border = "${base0D}ff";
        };
      };
    };

    wayland.windowManager.sway = {
      enable = true;
      extraSessionCommands = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        export QT_QPA_PLATFORM=wayland
        export MOZ_ENABLE_WAYLAND="1"
        export XDG_SESSION_TYPE="wayland"
        export XDG_CURRENT_DESKTOP="sway"
        export EGL_PLATFORM=wayland
        export NIXOS_OZONE_WL=1
      '';
      systemd.enable = true;
      config = {
        input = {
          "type:touchpad" = {
            accel_profile = "adaptive";
            pointer_accel = "0.9";
            dwt = "enabled";
            tap = "enabled";
            natural_scroll = "enabled";
          };
          "type:keyboard" = {
            xkb_layout = "eu";
            xkb_options = "compose:caps";
          };
          "2:10:TPPS/2_IBM_TrackPoint" = {
            middle_emulation = "enabled";
          };
        };
        output = {
          "*".bg = "${../../static/wallpapers/by_upload1_2560.jpg} fill";
        };
        modifier = "Mod4";
        terminal = config.bpletza.workstation.terminal.default;
        window = {
          titlebar = false;
          hideEdgeBorders = "smart";
          border = 1;
        };
        floating = {
          titlebar = false;
          criteria = [
            { "title" = "LibreWolf - Sharing Indicator"; }
            { "title" = "Firefox - Sharing Indicator"; }
            { "class" = "qemu"; }
            { "app_id" = "xdg-desktop-portal-gtk"; }
          ];
        };
        fonts = {
          names = [
            "Fira Code"
            "FontAwesome6Free"
          ];
          size = 9.0;
        };
        colors = with config.colorScheme.palette; {
          background = "#${base07}";
          focused = {
            border = "#${base05}";
            background = "#${base0D}";
            text = "#${base00}";
            indicator = "#${base0D}";
            childBorder = "#${base0D}";
          };
          focusedInactive = {
            border = "#${base01}";
            background = "#${base01}";
            text = "#${base05}";
            indicator = "#${base03}";
            childBorder = "#${base01}";
          };
          unfocused = {
            border = "#${base01}";
            background = "#${base00}";
            text = "#${base05}";
            indicator = "#${base01}";
            childBorder = "#${base01}";
          };
          urgent = {
            border = "#${base08}";
            background = "#${base08}";
            text = "#${base00}";
            indicator = "#${base08}";
            childBorder = "#${base08}";
          };
          placeholder = {
            border = "#${base00}";
            background = "#${base00}";
            text = "#${base05}";
            indicator = "#${base00}";
            childBorder = "#${base00}";
          };
        };
        bars = [
          {
            fonts = {
              names = [
                "Fira Code"
                "FontAwesome6Free"
              ];
              size = 9.0;
            };
            colors = with config.colorScheme.palette; {
              statusline = "#${base04}";
              background = "#${base00}";
              separator = "#${base01}";
              focusedWorkspace = {
                border = "#${base05}";
                background = "#${base0D}";
                text = "#${base00}";
              };
              activeWorkspace = {
                border = "#${base05}";
                background = "#${base03}";
                text = "#${base00}";
              };
              inactiveWorkspace = {
                border = "#${base03}";
                background = "#${base01}";
                text = "#${base05}";
              };
              urgentWorkspace = {
                border = "#${base08}";
                background = "#${base0B}";
                text = "#${base00}";
              };
              bindingMode = {
                border = "#${base00}";
                background = "#${base0A}";
                text = "#${base00}";
              };
            };
            position = "top";
            statusCommand = "${lib.getExe pkgs.i3status-rust} config-default.toml";
            extraConfig = ''
              status_padding 0
            '';
          }
        ];
        keybindings = lib.mkOptionDefault {
          "Mod4+Shift+e" = "exec wlogout";
          "Mod4+d" = "exec fuzzel";
          "Mod4+Ctrl+d" = "exec ${pkgs.wofi}/bin/wofi --show run";
          "Mod4+Shift+d" = "exec ${lib.getExe pkgs.emoji-picker}";
          "Mod4+p" = "exec ${lib.getExe pkgs.tessen}";
          "Mod4+Ctrl+l" = "exec loginctl lock-session";
          "Mod4+Ctrl+Left" = "move workspace to output left";
          "Mod4+Ctrl+Right" = "move workspace to output right";
          "Mod4+Ctrl+Up" = "move workspace to output up";
          "Mod4+Ctrl+Down" = "move workspace to output down";
          "XF86MonBrightnessDown" = "exec light -U 5 && light -G | cut -d'.' -f1 > $XDG_RUNTIME_DIR/wob.sock";
          "XF86MonBrightnessUp" = "exec light -A 5 && light -G | cut -d'.' -f1 > $XDG_RUNTIME_DIR/wob.sock";
          "XF86AudioMute" = "exec pamixer --toggle-mute && ( [ \"$(pamixer --get-mute)\" = \"true\" ] && echo 0 > $XDG_RUNTIME_DIR/wob.sock ) || pamixer --get-volume > $XDG_RUNTIME_DIR/wob.sock";
          "XF86AudioLowerVolume" = "exec pamixer -ud 2 && pamixer --get-volume > $XDG_RUNTIME_DIR/wob.sock";
          "XF86AudioRaiseVolume" = "exec pamixer -ui 2 && pamixer --get-volume > $XDG_RUNTIME_DIR/wob.sock";
          "Mod4+XF86AudioMute" = "exec pamixer --default-source --toggle-mute && ( [ \"$(pamixer --default-source --get-mute)\" = \"true\" ] && echo 0 > $XDG_RUNTIME_DIR/wob.sock ) || pamixer --default-source --get-volume > $XDG_RUNTIME_DIR/wob.sock";
          "XF86AudioMicMute" = "exec pamixer --default-source --toggle-mute && ( [ \"$(pamixer --default-source --get-mute)\" = \"true\" ] && echo 0 > $XDG_RUNTIME_DIR/wob.sock ) || pamixer --default-source --get-volume > $XDG_RUNTIME_DIR/wob.sock";
          "Mod4+XF86AudioLowerVolume" = "exec pamixer --default-source -ud 2 && pamixer --default-source --get-volume > $XDG_RUNTIME_DIR/wob.sock";
          "Mod4+XF86AudioRaiseVolume" = "exec pamixer --default-source -ui 2 && pamixer --default-source --get-volume > $XDG_RUNTIME_DIR/wob.sock";
        };
        keycodebindings = {
          "275" = "exec ${pkgs.glib}/bin/gdbus call -e -d net.sourceforge.mumble.mumble -o / -m net.sourceforge.mumble.Mumble.startTalking";
          "--release 275" = "exec ${pkgs.glib}/bin/gdbus call -e -d net.sourceforge.mumble.mumble -o / -m net.sourceforge.mumble.Mumble.stopTalking";
        };
        modes = {
          resize = {
            Down = "resize grow height 5 px";
            Escape = "mode default";
            Left = "resize shrink width 5 px";
            Return = "mode default";
            Right = "resize grow width 5 px";
            Up = "resize shrink height 5 px";
            h = "resize shrink width 5 px";
            j = "resize grow height 5 px";
            k = "resize shrink height 5 px";
            l = "resize grow width 5 px";
          };
        };
        startup = [
          # we only manage displays in kanshi thus we need to reload on sway reload
          {
            command = "${pkgs.kanshi}/bin/kanshictl reload";
            always = true;
          }
        ];
      };
      wrapperFeatures.gtk = true;
    };

    services.kanshi = {
      enable = true;
      settings = [
        {
          profile.name = "undocked";
          profile.outputs = [
            {
              criteria = "eDP-1";
              position = "0,0";
            }
          ];
        }
        {
          profile.name = "home";
          profile.outputs = [
            {
              criteria = "Dell Inc. DELL U2520D 8KQLGZ2";
              position = "0,0";
            }
            {
              criteria = "Dell Inc. DELL U2520D 79PLGZ2";
              position = "2560,0";
            }
          ];
        }
        {
          profile.name = "home-docked";
          profile.outputs = [
            {
              criteria = "Dell Inc. DELL U2520D 8KQLGZ2";
              position = "0,0";
            }
            {
              criteria = "Dell Inc. DELL U2520D 79PLGZ2";
              position = "2560,0";
            }
            {
              criteria = "eDP-1";
              position = "0,1440";
            }
          ];
        }
      ];
    };

    systemd.user.services.caffeinated = {
      Unit = {
        PartOf = [ "sway-session.target" ];
        After = [ "sway-session.target" ];
        ConditionEnvironment = [ "WAYLAND_DISPLAY" ];
      };
      Service = {
        ExecStart = "${pkgs.caffeinated}/bin/caffeinated";
        Restart = "on-failure";
      };
    };

    programs.wlogout = {
      enable = true;
      layout = [
        {
          label = "lock";
          action = "loginctl lock-session";
          text = "Lock";
          keybind = "l";
        }
        {
          label = "logout";
          action = "loginctl terminate-user $USER";
          text = "Logout";
          keybind = "e";
        }
        {
          label = "reboot";
          action = "systemctl reboot";
          text = "Reboot";
          keybind = "r";
        }
        {
          label = "hibernate";
          action = "systemctl hibernate";
          text = "Hibernate";
          keybind = "h";
        }
        {
          label = "suspend";
          action = "systemctl suspend";
          text = "Suspend";
          keybind = "u";
        }
        {
          label = "shutdown";
          action = "systemctl poweroff";
          text = "Shutdown";
          keybind = "s";
        }
      ];
    };
  };
}
