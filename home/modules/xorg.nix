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
        theme =
          let
            inherit (config.lib.formats.rasi) mkLiteral;
            inherit (config.colorScheme.palette)
              base00
              base01
              base05
              base06
              base08
              base0D
              ;
          in
          {
            "*" = {
              red = mkLiteral "#${base08}ff";
              blue = mkLiteral "#${base0D}ff";
              lightfg = mkLiteral "#${base06}ff";
              lightbg = mkLiteral "#${base01}ff";
              foreground = mkLiteral "#${base05}";
              background = mkLiteral "#${base00}";
              background-color = mkLiteral "#${base00}cc";
              separatorcolor = mkLiteral "@foreground";
              border-color = mkLiteral "@foreground";
              selected-normal-foreground = mkLiteral "@lightbg";
              selected-normal-background = mkLiteral "@lightfg";
              selected-active-foreground = mkLiteral "@background";
              selected-active-background = mkLiteral "@blue";
              selected-urgent-foreground = mkLiteral "@background";
              selected-urgent-background = mkLiteral "@red";
              normal-foreground = mkLiteral "@foreground";
              normal-background = mkLiteral "@background";
              active-foreground = mkLiteral "@blue";
              active-background = mkLiteral "@background";
              urgent-foreground = mkLiteral "@red";
              urgent-background = mkLiteral "@background";
              alternate-normal-foreground = mkLiteral "@foreground";
              alternate-normal-background = mkLiteral "@lightbg";
              alternate-active-foreground = mkLiteral "@blue";
              alternate-active-background = mkLiteral "@lightbg";
              alternate-urgent-foreground = mkLiteral "@red";
              alternate-urgent-background = mkLiteral "@lightbg";
              spacing = 2;
            };
            window = {
              background-color = mkLiteral "@background";
              border = 1;
              padding = 5;
            };
            mainbox = {
              border = 0;
              padding = 0;
            };
            message = {
              border = mkLiteral "1px dash 0px 0px";
              border-color = mkLiteral "@separatorcolor";
              padding = mkLiteral "1px";
            };
            textbox = {
              text-color = mkLiteral "@foreground";
            };
            listview = {
              fixed-height = 0;
              border = mkLiteral "2px dash 0px 0px";
              border-color = mkLiteral "@separatorcolor";
              spacing = mkLiteral "2px";
              scrollbar = true;
              padding = mkLiteral "2px 0px 0px";
            };
            "element-text, element-icon" = {
              background-color = mkLiteral "inherit";
              text-color = mkLiteral "inherit";
            };
            element = {
              border = 0;
              padding = mkLiteral "1px";
            };
            "element normal.normal" = {
              background-color = mkLiteral "@normal-background";
              text-color = mkLiteral "@normal-foreground";
            };
            "element normal.urgent" = {
              background-color = mkLiteral "@urgent-background";
              text-color = mkLiteral "@urgent-foreground";
            };
            "element normal.active" = {
              background-color = mkLiteral "@active-background";
              text-color = mkLiteral "@active-foreground";
            };
            "element selected.normal" = {
              background-color = mkLiteral "@selected-normal-background";
              text-color = mkLiteral "@selected-normal-foreground";
            };
            "element selected.urgent" = {
              background-color = mkLiteral "@selected-urgent-background";
              text-color = mkLiteral "@selected-urgent-foreground";
            };
            "element selected.active" = {
              background-color = mkLiteral "@selected-active-background";
              text-color = mkLiteral "@selected-active-foreground";
            };
            "element alternate.normal" = {
              background-color = mkLiteral "@alternate-normal-background";
              text-color = mkLiteral "@alternate-normal-foreground";
            };
            "element alternate.urgent" = {
              background-color = mkLiteral "@alternate-urgent-background";
              text-color = mkLiteral "@alternate-urgent-foreground";
            };
            "element alternate.active" = {
              background-color = mkLiteral "@alternate-active-background";
              text-color = mkLiteral "@alternate-active-foreground";
            };
            scrollbar = {
              width = mkLiteral "4px";
              border = 0;
              handle-color = mkLiteral "@normal-foreground";
              handle-width = mkLiteral "8px";
              padding = 0;
            };
            sidebar = {
              border = mkLiteral "2px dash 0px 0px";
              border-color = mkLiteral "@separatorcolor";
            };
            button = {
              spacing = 0;
              text-color = mkLiteral "@normal-foreground";
            };
            "button selected" = {
              background-color = mkLiteral "@selected-normal-background";
              text-color = mkLiteral "@selected-normal-foreground";
            };
            inputbar = {
              spacing = mkLiteral "0px";
              text-color = mkLiteral "@normal-foreground";
              padding = mkLiteral "1px";
              children = mkLiteral "[ prompt,textbox-prompt-colon,entry,case-indicator ]";
            };
            case-indicator = {
              spacing = 0;
              text-color = mkLiteral "@normal-foreground";
            };
            entry = {
              spacing = 0;
              text-color = mkLiteral "@normal-foreground";
            };
            prompt = {
              spacing = 0;
              text-color = mkLiteral "@normal-foreground";
            };
            textbox-prompt-colon = {
              expand = false;
              str = " = ";
              margin = mkLiteral "0px 0.3000em 0.0000em 0.0000em";
              text-color = mkLiteral "inherit";
            };
          };
        pass.enable = true;
        terminal = config.bpletza.workstation.terminal.default;
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
            terminal = config.bpletza.workstation.terminal.default;
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
              "Mod4+p" = "exec rofi-pass";
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
