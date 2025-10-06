{
  osConfig,
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.bpletza.workstation.waybar;

  fuzzelMenuWrapped =
    pkg:
    pkgs.writers.writeBash "${pkg.pname}-fuzzel" ''
      PATH=${lib.makeBinPath [ pkgs.fuzzel ]}
      ${lib.getExe pkg} --launcher fuzzel
    '';
in
{
  options.bpletza.workstation.waybar = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = config.bpletza.workstation.sway;
    };
  };

  config = {
    systemd.user.services.waybar.Install.WantedBy = [
      "sway-session.target"
    ];

    programs.waybar = {
      enable = cfg.enable;
      systemd = {
        enable = true;
        target = "wayland-session@sway.target";
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
          "temperature"
          "backlight"
        ];
        modules-center = [
          "mpris"
        ];
        modules-right = [
          "network#en"
          "network#enu"
          "network#wl"
          "bluetooth"
          "pulseaudio"
          "upower"
          "clock"
          "tray"
        ];
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
          on-scroll-up = "swayosd-client --brightness raise";
          on-scroll-down = "swayosd-client --brightness lower";
        };
        power-profiles-daemon = {
          format-icons = {
            default = "⏻";
            performance = "";
            balanced = "";
            power-saver = "";
          };
        };
        temperature = {
          interval = 2;
          format = "{temperatureC}°C {icon} ";
          format-icons = [
            "󱃃"
            "󰔏"
            "󱃂"
          ];
          warning-threshold = 80;
          critical-thrshold = 90;
        };
        upower = {
          icon-size = 16;
          format = "{percentage} {time}";
        };
        "network#en" = {
          interface = osConfig.bpletza.workstation.waybar.wiredInterface;
          family = "ipv4_6";
          format-ethernet = "{bandwidthDownBits} {bandwidthUpBits} ";
          tooltip-format-ethernet = "{ifname}";
          format-linked = "{ifname} (No IP) ";
          format-disconnected = "";
          format-alt = "{ifname} {ipaddr}/{cidr}";
          interval = 2;
        };
        "network#enu" = {
          interface = "en*u*";
          family = "ipv4_6";
          format-ethernet = "{bandwidthDownBits} {bandwidthUpBits} 󰕓";
          tooltip-format-ethernet = "{ifname}";
          format-linked = "{ifname} (No IP) 󰕓";
          format-disconnected = "";
          format-alt = "{ifname} {ipaddr}/{cidr}";
          interval = 2;
        };
        "network#wl" = {
          interface = "wl*";
          family = "ipv4_6";
          format-wifi = "{bandwidthDownBits} {bandwidthUpBits} {essid} {icon}";
          tooltip-format-wifi = "{ifname}";
          format-linked = "{ifname} (No IP) {icon}";
          format-disconnected = "󰤭";
          format-alt = "{ifname} {ipaddr}/{cidr}";
          format-icons = [
            "󰤟"
            "󰤢"
            "󰤥"
            "󰤨"
          ];
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
          on-click = "${lib.getExe config.bpletza.workstation.terminal.default} -e ${lib.getExe pkgs.wiremix}";
        };
        bluetooth = {
          format = "{status} ";
          format-no-controller = "";
          format-disabled = "";
          format-on = "";
          format-off = "󰂲";
          format-connected = "{device_alias} ";
          format-connected-battery = "{device_alias} {device_battery_percentage}% ";
          tooltip-format = "{controller_alias}\t{controller_address}\n\n{num_connections} connected";
          tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{num_connections} connected\n\n{device_enumerate}";
          tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
          tooltip-format-enumerate-connected-battery = "{device_alias}\t{device_address}\t{device_battery_percentage}%";
          on-click = fuzzelMenuWrapped pkgs.bzmenu;
        };
        mpris = {
          format = "{player_icon} {dynamic}";
          format-paused = "{status_icon} <i>{dynamic}</i>";
          dynamic-order = [
            "title"
            "artist"
          ];
          ignored-players = [
            "firefox"
            "librewolf"
            "chromium"
          ];
          player-icons = {
            default = "▶";
            spotify = "";
            spotifyd = "";
            firefox = "";
            librewolf = "";
            chromium = "";
            YoutubeMusic = "";
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
      style = # css
        ''
          * {
            margin: 0;
            border-radius: 0;
          }

          #workspaces button {
            padding: 0 5px;
          }

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
          #temperature,
          #mpris,
          #tray {
            padding: 0 5px;
          }

          #bluetooth, #temperature {
            color: @base0C;
          }

          #bluetooth.off, #bluetooth.disabled {
            color: @base05;
          }

          #mpris {
            color: @base0E;
          }

          #disk {
            color: @base0B;
          }

          #mode,
          #idle_inhibitor.activated {
            color: @base08;
          }

          #clock, #backlight {
            color: @base0E;
          }

          #upower {
            color: @base0B;
          }

          #upower.charging {
            color: @base0B;
          }

          #systemd-failed-units.ok, #mpris.spotify {
            color: @base0B;
          }

          #systemd-failed-units.degraded {
            color: @base08;
          }

          #upower.discharging {
            color: @base07;
          }

          #network, #network-wl,
          #temperature.critical,
          #bluetooth.discoverable {
            color: @base08;
          }

          #pulseaudio, #mpris.paused, #power-profiles-daemon {
            color: @base0A;
          }
        '';
    };
  };
}
