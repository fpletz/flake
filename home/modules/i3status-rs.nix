{
  config,
  osConfig,
  lib,
  pkgs,
  ...
}:
{
  options.bpletza.workstation.i3status-rs = lib.mkOption {
    type = lib.types.bool;
    default = config.bpletza.workstation.sway;
  };

  config = lib.mkIf config.bpletza.workstation.i3status-rs {
    programs.i3status-rust = {
      enable = true;
      bars.default = {
        blocks =
          [
            {
              block = "focused_window";
              format = " $title.str(max_w:64) |";
            }
            {
              block = "custom";
              command = "curl -s https://tgftp.nws.noaa.gov/data/observations/metar/stations/EDDM.TXT | tail -n1";
              interval = 300;
            }
            {
              block = "music";
              interface_name_exclude = [
                "firefox"
                "chromium"
                "playerctld"
              ];
              format = " $icon {$combo.str(max_w:75,rot_interval:0.5,rot_separator:' | ') $play $next |}";
            }
            {
              block = "sound";
              driver = "pulseaudio";
              step_width = 2;
              device_kind = "sink";
              headphones_indicator = true;
            }
            {
              block = "sound";
              driver = "pulseaudio";
              step_width = 2;
              device_kind = "source";
            }
            {
              block = "bluetooth";
              mac = "88:C9:E8:DF:29:88"; # WF-1000XM4
              format = " $icon{ $percentage|} ";
              disconnected_format = "";
            }
            {
              block = "bluetooth";
              mac = "04:5D:4B:83:4B:88"; # MDR-1000X
              format = " $icon{ $percentage|} ";
              disconnected_format = "";
            }
            {
              block = "net";
              device = "^wl.*";
              missing_format = "";
              format = " $icon $ssid $signal_strength ^icon_net_down $speed_down.eng(prefix:K) ^icon_net_up $speed_up.eng(prefix:K) ";
            }
            {
              block = "net";
              device = "^en.*";
              missing_format = "";
            }
            {
              block = "disk_space";
              path = "/";
              interval = 30;
              alert_unit = "GB";
              warning = 20.0;
              alert = 10.0;
            }
            {
              block = "load";
              interval = 1;
            }
            {
              block = "toggle";
              if_command = "swaymsg -t get_inputs";
              command_on = "systemctl --user start caffeinated";
              command_off = "systemctl --user stop caffeinated";
              command_state = pkgs.writers.writeBash "i3status-rs-caffeinated-state" ''
                systemctl --user status caffeinated 2>&1 >/dev/null
                if [ "$?" == "0" ]; then
                  echo true
                fi
              '';
              format = " $icon  ";
            }
          ]
          ++ osConfig.bpletza.workstation.i3status-rs.blocks.temperatures or [ ]
          ++ lib.optional (osConfig.bpletza.workstation.battery or false) {
            block = "battery";
            driver = "upower";
            format = " $icon $percentage ";
            full_format = " $icon ";
            empty_format = " $icon $percentage ";
            not_charging_format = " $icon $percentage ";
            missing_format = "";
            full_threshold = 80;
            empty_threshold = 5;
          }
          ++ [
            {
              block = "time";
              interval = 3;
              format = " $timestamp.datetime(f:'%a %d %b %R') ";
              timezone = "Europe/Amsterdam";
            }
          ];
        settings = {
          theme = {
            theme = "slick";
            overrides = with config.colorScheme.palette; {
              idle_bg = "#${base00}";
              idle_fg = "#${base05}";
              info_bg = "#${base0C}";
              info_fg = "#${base00}";
              good_bg = "#${base0B}";
              good_fg = "#${base00}";
              warning_bg = "#${base0A}";
              warning_fg = "#${base00}";
              critical_bg = "#${base08}";
              critical_fg = "#${base00}";
            };
          };
          icons = {
            icons = "awesome6";
          };
        };
      };
    };
  };
}
