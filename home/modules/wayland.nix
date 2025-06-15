{
  osConfig,
  config,
  lib,
  pkgs,
  ...
}:
let
  oscfg = osConfig.bpletza.workstation;
in
{
  options.bpletza.workstation.wayland = lib.mkOption {
    type = lib.types.bool;
    default = config.bpletza.workstation.enable;
  };

  config = lib.mkIf config.bpletza.workstation.wayland {
    home.packages = [
      pkgs.libnotify
      pkgs.kanshi
      pkgs.wdisplays
      pkgs.swaybg
      pkgs.grim
      pkgs.slurp
      pkgs.waypipe
      pkgs.wev
      pkgs.wf-recorder
      pkgs.wl-clipboard
      pkgs.wl-mirror
      pkgs.wlr-randr
      pkgs.wtype
      pkgs.tessen
      pkgs.emoji-picker
    ];

    home.file.".config/niri/config.kdl".source = ../../static/niri.kdl;

    services.swayosd = {
      enable = true;
    };

    services.fnott = {
      enable = true;
      extraFlags = [ "-s" ];
      settings = (
        with config.colorScheme.palette;
        {
          main = {
            background = "${base00}ff";
            border-color = "${base0D}ff";
            title-color = "${base05}ff";
            summary-color = "${base05}ff";
            body-color = "${base05}ff";
            progress-bar-color = "${base0D}ff";
            icon-theme = config.gtk.iconTheme.name;
            max-icon-size = 64;
            # default-timeout = 10;
            # max-timeout = 30;
            min-width = 300;
            max-width = 1000;
            title-font = "Recursive Sans Casual Static:size=11";
            summary-font = "Recursive Sans Casual Static:size=11";
            body-font = "Recursive Sans Casual Static:size=11";
            selection-helper = "${lib.getExe pkgs.fuzzel} -d";
            summary-format = "<b>%s</b>";
            padding-vertical = 15;
            padding-horizontal = 15;

          };
          low = {
            background = "${base00}ff";
            title-color = "${base0A}ff";
            summary-color = "${base0A}ff";
            body-color = "${base0A}ff";
          };
          critical = {
            background = "${base00}ff";
            title-color = "${base08}ff";
            summary-color = "${base08}ff";
            body-color = "${base08}ff";
          };
        }
      );
    };

    programs.fuzzel = {
      enable = true;
      settings = {
        main = {
          terminal = config.bpletza.workstation.terminal.default;
          dpi-aware = false;
          font = "Recursive Sans Casual Static:size=11";
          icon-theme = config.gtk.iconTheme.name;
          show-actions = true;
          use-bold = true;
        };
        colors = {
          # https://github.com/folke/tokyonight.nvim/blob/main/extras/fuzzel/tokyonight_night.ini
          background = "16161eff";
          text = "c0caf5ff";
          match = "2ac3deff";
          selection = "343a55ff";
          selection-match = "2ac3deff";
          selection-text = "c0caf5ff";
          border = "27a1b9ff";
        };
      };
    };

    services.kanshi = {
      enable = true;
      settings =
        [
          {
            output = {
              criteria = "Dell Inc. DELL U2520D 8KQLGZ2";
              status = "enable";
              position = "0,0";
              alias = "home-left";
            };
          }
          {
            output = {
              criteria = "Dell Inc. DELL U2520D 79PLGZ2";
              status = "enable";
              position = "2560,0";
              alias = "home-right";
            };
          }
          {
            output = {
              criteria = "PNP(AOC) U2790B 0x0000579E";
              status = "enable";
              alias = "muccc1";
              scale = 1.5;
            };
          }
          {
            output = {
              criteria = "Dell Inc. DELL U2713HM GK0KD2AC662L";
              status = "enable";
              alias = "muccc2";
            };
          }
        ]
        ++ (lib.optionals (oscfg.internalDisplay != null) [
          {
            output = {
              criteria = oscfg.internalDisplay;
              status = "enable";
              alias = "internal";
              scale = lib.mkIf (!isNull oscfg.displayScale) oscfg.displayScale;
            };
          }
          {
            profile = {
              name = "undocked";
              outputs = [
                {
                  criteria = "$internal";
                  position = "0,0";
                }
              ];
            };
          }
          {
            profile = {
              name = "home-docked";
              outputs = [
                { criteria = "$home-left"; }
                { criteria = "$home-right"; }
                {
                  criteria = "$internal";
                  status = "disable";
                  position = "0,1440";
                }
              ];
            };
          }
          {
            profile = {
              name = "muccc1-docked";
              outputs = [
                {
                  criteria = "$muccc1";
                  position = "0,0";
                }
                {
                  criteria = "$internal";
                  position = "0,1440";
                }
              ];
            };
          }
          {
            profile = {
              name = "muccc2-docked";
              outputs = [
                {
                  criteria = "$muccc2";
                  position = "0,0";
                }
                {
                  criteria = "$internal";
                  position = "0,1200";
                }
              ];
            };
          }
          {
            profile = {
              name = "projector";
              outputs = [
                {
                  criteria = "HDMI-A-1";
                  position = "0,0";
                }
                {
                  criteria = "$internal";
                  position = "0,1080";
                }
              ];
            };
          }
        ]);
    };

    systemd.user.services.swww = {
      Unit = {
        Description = "swww";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
        ConditionEnvironment = "WAYLAND_DISPLAY";
      };
      Service = {
        ExecStart = "${lib.getExe' pkgs.swww "swww-daemon"} --format xbgr";
        Restart = "on-failure";
        Environment = "PATH=${lib.getBin pkgs.swww}/bin";
      };
      Install.WantedBy = [ "graphical-session.target" ];
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
