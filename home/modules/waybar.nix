{
  osConfig,
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.bpletza.workstation.waybar;
in
{
  options.bpletza.workstation.waybar = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = config.bpletza.workstation.sway;
    };
  };

  config = {
    programs.waybar = {
      enable = cfg.enable;
      package = pkgs.waybar.override {
        hyprlandSupport = false;
      };
      systemd = {
        enable = true;
        target = lib.mkIf config.bpletza.workstation.sway "sway-session.target";
      };
      settings.mainBar = {
        layer = "top";
        position = "top";
        reload_style_on_change = true;
        modules-left = [
          "sway/workspaces"
          "sway/mode"
          "idle_inhibitor"
          "privacy"
          "systemd-failed-units"
          "power-profiles-daemon"
          # "load"
          # "memory"
          # "disk"
          "backlight"
        ];
        modules-center = [
          #"sway/window"
          # "mpris"
        ];
        modules-right = [
          "network"
          "network#wl"
          "bluetooth"
          "pulseaudio"
          "upower"
          "clock"
          "tray"
        ];
        "sway/workspaces" = { };
        "sway/mode" = {
          format = " {}";
        };
        privacy = {
          icon-size = 16;
          modules = [
            {
              type = "screenshare";
              tooltip = true;
              tooltip-icon-size = 16;
            }
            {
              type = "audio-in";
              tooltip = true;
              tooltip-icon-size = 16;
            }
          ];
        };
        idle_inhibitor = {
          format = "{icon}";
          format-icons = {
            activated = "";
            deactivated = "";
          };
        };
        load = {
          format = "{load1} 󰣖";
          interval = 2;
        };
        memory = {
          format = "{percentage}%/{swapPercentage}% ";
          interval = 2;
        };
        disk = {
          format = "{free} {path}";
          path = "/";
        };
        clock = {
          timezones = [
            "Europe/Amsterdam"
            "UTC"
          ];
          format = "{:%H:%M %Z} ";
          format-alt = "{:%a %F} ";
          interval = 5;
          tooltip-format = "<big>{:%Y}</big>\n<tt><small>{calendar}</small></tt>";
          calendar = {
            mode = "year";
            mode-mon-col = 3;
            week-pos = "left";
          };
          actions = {
            on-click-left = "mode";
            on-scroll-up = "tz_up";
            on-scroll-down = "tz_down";
          };
        };
        backlight = {
          format = "{percent} {icon}";
          format-icons = [
            ""
            ""
            ""
            ""
            ""
            ""
            ""
            ""
            ""
          ];
          on-scroll-up = "${lib.getExe pkgs.light} -U 5";
          on-scroll-down = "${lib.getExe pkgs.light} -A 5";
        };
        power-profiles-daemon = {
          format-icons = {
            default = "";
            performance = "";
            balanced = "";
            power-saver = "";
          };
        };
        upower = {
          icon-size = 16;
        };
        network = {
          interface = osConfig.bpletza.workstation.waybar.wiredInterface;
          format-ethernet = "{bandwidthDownBits} {bandwidthUpBits} ";
          tooltip-format-ethernet = "{ifname} {ipaddr}/{cidr} via {gwaddr}";
          format-linked = "{ifname} (No IP) ";
          format-disconnected = "";
          format-alt = "{ifname} {ipaddr}/{cidr}";
          interval = 2;
        };
        "network#wl" = {
          interface = "wlp*";
          format-wifi = "{bandwidthDownBits} {bandwidthUpBits} {essid} {signalStrength}% ";
          tooltip-format-wifi = "{ipaddr}/{cidr} via {gwaddr} with {signaldBm}dBm";
          format-linked = "{ifname} (No IP) ";
          format-disconnected = "";
          format-alt = "{ifname} {ipaddr}/{cidr}";
          interval = 2;
        };
        pulseaudio = {
          scroll-step = 1;
          format = "{volume}% {icon} {format_source}";
          format-bluetooth = "{volume}% {icon} {format_source}";
          format-bluetooth-muted = " {icon} {format_source}";
          format-muted = " {format_source}";
          format-source = "{volume}% ";
          format-source-muted = "";
          format-icons = {
            headphone = "󰋋";
            hands-free = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = [
              ""
              ""
              ""
            ];
          };
          on-click = "${config.bpletza.workstation.terminal.default} -e ${lib.getExe pkgs.pulsemixer}";
        };
        bluetooth = {
          format = " {status}";
          format-no-controller = "";
          format-disabled = "";
          format-on = "";
          format-off = "󰂲";
          format-connected = " {device_alias}";
          format-connected-battery = " {device_alias} {device_battery_percentage}%";
          tooltip-format = "{controller_alias}\t{controller_address}\n\n{num_connections} connected";
          tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{num_connections} connected\n\n{device_enumerate}";
          tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
          tooltip-format-enumerate-connected-battery = "{device_alias}\t{device_address}\t{device_battery_percentage}%";
        };
        mpris = {
          format = "{player_icon} {dynamic}";
          format-paused = "{status_icon} <i>{dynamic}</i>";
          dynamic-order = [
            "title"
            "artist"
          ];
          player-icons = {
            default = "▶";
            spotify = "";
            spotifyd = "";
            firefox = "";
            librewolf = "";
            chromium = "";
          };
          status-icons = {
            paused = "";
          };
        };
        systemd-failed-units = {
          hide-on-ok = false;
          format = "✗ {nr_failed}";
          format-ok = "✓";
          system = true;
          user = true;
        };
      };
      style = ''
        * {
          border: none;
          border-radius: 0;
          font-family: "Recursive Sans Casual Static";
          font-size: 10pt;
          min-height: 0;
        }

        window#waybar {
          background-color: rgba(0,0,0,0);
          color: #A9B1D6;
        }

        #workspaces {
          background-color: #24283b;
          margin: 0px;
          border-radius: 5px;
        }

        #workspaces button {
          padding: 5px 5px;
          color: #c0caf5;
        }

        #workspaces button.focused {
          color: #24283b;
          background-color: #7aa2f7;
          border-radius: 5px;
        }

        #workspaces button:hover {
          background-color: #7dcfff;
          color: #24283b;
          border-radius: 5px;
        }

        #load,
        #memory,
        #disk,
        #mode,
        #privacy,
        #idle_inhibitor,
        #backlight,
        #clock,
        #power-profiles-daemon,
        #upower,
        #pulseaudio,
        #bluetooth,
        #network,
        #network-wl,
        #systemd-failed-units,
        #tray {
          background-color: #24283b;
          padding: 5px 10px;
          margin: 0px 2px;
          border-radius: 5px;
        }

        #load, #bluetooth {
          color: #7dcfff;
        }

        #bluetooth.off, #bluetooth.disabled {
          color: #a9b1d6;
        }

        #memory {
          color: #bb9af7;
        }

        #disk {
          color: #9ece6a;
        }

        #tray {
          margin: 0;
        }

        #mode,
        #idle_inhibitor.activated {
          color: #24283b;
          background-color: #7aa2f7;
        }

        #clock {
          color: #bb9af7;
          border-radius: 0px 5px 5px 0px;
        }

        #upower {
          color: #9ece6a;
        }

        #upower.charging {
          color: #9ece6a;
        }

        #systemd-failed-units.ok {
          color: #9ece6a;
        }

        #systemd-failed-units.degraded {
          color: #f7768e;
        }

        #upower.discharging {
          background-color: #f7768e;
          color: #24283b;
        }

        #network, #network-wl, #bluetooth.discoverable {
          color: #f7768e;
        }

        #pulseaudio {
          color: #e0af68;
        }
      '';
    };

  };
}
