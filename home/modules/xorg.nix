{
  lib,
  config,
  osConfig,
  pkgs,
  ...
}:
{
  options.bpletza.workstation = {
    xorg = lib.mkOption {
      type = lib.types.bool;
      default = osConfig.bpletza.workstation.xorg;
    };
    xorg-settings = lib.mkOption {
      type = lib.types.bool;
      default = osConfig.bpletza.workstation.xorg || config.bpletza.workstation.sway;
    };
  };

  config = lib.mkMerge [
    (lib.mkIf config.bpletza.workstation.xorg-settings {
      xresources.properties = {
        "Xft.hinting" = "1";
        "Xft.hintstyle" = "hintslight";
        "Xft.antialias" = "1";
        "Xft.rgba" = "rgb";
      };

      services.xsettingsd = {
        enable = true;
        settings = {
          "Xft/Hinting" = true;
          "Xft/HintStyle" = "hintslight";
          "Xft/Antialias" = true;
          "Xft/RGBA" = "rgb";
        };
      };
    })

    (lib.mkIf config.bpletza.workstation.xorg {
      programs.autorandr.enable = true;

      home.packages = with pkgs; [ xclip ];

      programs.rofi = {
        enable = true;
        font = "Inter Display 10";
        theme = "Arc-Dark";
        pass.enable = true;
      };

      services.dunst = {
        enable = true;
        iconTheme = {
          name = "Tokyonight-Dark";
          package = pkgs.tokyonight-gtk-theme-variants.icons.dark;
        };
        settings = with config.colorScheme.palette; {
          global = {
            transparency = 10;
            font = "Fira Sans 10";
            frame_color = "#${base05}";
            separator_color = "#${base05}";
          };
          base16_low = {
            msg_urgency = "low";
            background = "#${base01}";
            foreground = "#${base03}";
          };
          base16_normal = {
            msg_urgency = "normal";
            background = "#${base02}";
            foreground = "#${base05}";
          };
          base16_critical = {
            msg_urgency = "critical";
            background = "#${base08}";
            foreground = "#${base06}";
          };
        };
      };

      xsession = {
        enable = true;
        scriptPath = ".xinitrc";
        windowManager.i3 = {
          enable = true;
          config = {
            modifier = "Mod4";
            terminal = "kitty";
            menu = "rofi -show run";
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
              ];
            };
            fonts = {
              names = [
                "Fira Code"
                "FontAwesome6Free"
              ];
              size = 8.0;
            };
            bars = [
              {
                fonts = {
                  names = [
                    "Fira Code"
                    "FontAwesome6Free"
                  ];
                  size = 8.0;
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
              }
            ];
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

            keybindings = lib.mkOptionDefault {
              "Mod4+p" = "exec passmenu";
              "Mod4+Shift+p" = "exec rofi-pass";
              "Mod4+Ctrl+l" = "exec loginctl lock-session";
              "Mod4+h" = "focus left";
              "Mod4+j" = "focus down";
              "Mod4+k" = "focus up";
              "Mod4+l" = "focus right";
              "Mod4+Shift+h" = "move left";
              "Mod4+Shift+j" = "move down";
              "Mod4+Shift+k" = "move up";
              "Mod4+Shift+l" = "move right";
              "Mod4+Ctrl+Left" = "move workspace to output left";
              "Mod4+Ctrl+Right" = "move workspace to output right";
              "Mod4+Ctrl+Up" = "move workspace to output up";
              "Mod4+Ctrl+Down" = "move workspace to output down";
              "XF86MonBrightnessDown" = "exec light -U 5 && light -G";
              "XF86MonBrightnessUp" = "exec light -A 5 && light -G";
              "XF86AudioMute" = "exec pamixer --toggle-mute";
              "XF86AudioLowerVolume" = "exec pamixer -ud 2";
              "XF86AudioRaiseVolume" = "exec pamixer -ui 2";
              "Mod4+XF86AudioMute" = "exec pamixer --default-source --toggle-mute";
              "XF86AudioMicMute" = "exec pamixer --default-source --toggle-mute";
              "Mod4+XF86AudioLowerVolume" = "exec pamixer --default-source -ud 2";
              "Mod4+XF86AudioRaiseVolume" = "exec pamixer --default-source -ui 2";
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
          };
          extraConfig = ''
            exec --no-startup-id ${lib.getExe pkgs.feh} --bg-fill ${../../static/wallpapers/wallhaven-p97l5e.png}
          '';
        };
      };
    })
  ];
}
