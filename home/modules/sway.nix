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
    services.mako = with config.colorScheme.palette; {
      enable = true;
      font = "Inter Display 10";
      iconPath = "${pkgs.tokyonight-gtk-theme-variants.icons.dark}/share/icons/Tokyonight-Dark";
      backgroundColor = "#${base00}";
      textColor = "#${base08}";
      borderColor = "#7dcfff";
      defaultTimeout = 5000;
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
          "*".bg = "${../../static/wallpapers/wallhaven-p97l5e.png} fill";
        };
        modifier = "Mod4";
        terminal = "kitty";
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
        colors = {
          background = "$base";
          focused = {
            border = "$teal";
            background = "$base";
            text = "$text";
            indicator = "$teal";
            childBorder = "$teal";
          };
          focusedInactive = {
            border = "$mauve";
            background = "$base";
            text = "$text";
            indicator = "$lavender";
            childBorder = "$lavender";
          };
          unfocused = {
            border = "$mauve";
            background = "$base";
            text = "$text";
            indicator = "$lavender";
            childBorder = "$lavender";
          };
          urgent = {
            border = "$peach";
            background = "$base";
            text = "$peach";
            indicator = "$overlay0";
            childBorder = "$maroon";
          };
          placeholder = {
            border = "$overlay0";
            background = "$base";
            text = "$text";
            indicator = "$overlay0";
            childBorder = "$overlay0";
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
        keybindings =
          let
            wofi-pass =
              {
                type ? false,
              }:
              pkgs.writers.writeBash "wofi-pass" ''
                password=$(${pkgs.fd}/bin/fd --base-directory ''${PASSWORD_STORE_DIR-~/.password-store} --extension gpg |
                  ${pkgs.gnused}/bin/sed 's,\.gpg,,' | ${pkgs.wofi}/bin/wofi -p pass --dmenu "$@")

                [[ -n $password ]] || exit

                ${pkgs.gopass}/bin/gopass show -c "$password" 2>/dev/null ${lib.optionalString type "| ${pkgs.wtype}/bin/wtype -"}
              '';
          in
          lib.mkOptionDefault {
            "Mod4+Shift+e" = "exec wlogout";
            "Mod4+d" = "exec ${pkgs.wofi}/bin/wofi --show run";
            "Mod4+Shift+d" = "exec ${pkgs.wofi-emoji}/bin/wofi-emoji";
            "Mod4+p" = "exec ${wofi-pass { }}";
            "Mod4+Ctrl+p" = "exec ${wofi-pass { type = true; }}";
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
      extraConfigEarly = ''
        include ${
          pkgs.fetchurl {
            url = "https://raw.githubusercontent.com/catppuccin/i3/main/themes/catppuccin-mocha";
            hash = "sha256-eeMloj3UgVMF0zUQBMIiJkqabVeUW/ff1jTarAd4dwI=";
          }
        }
      '';
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
