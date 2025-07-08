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
      pkgs.iwmenu
      pkgs.bzmenu
      pkgs.shikane
    ];

    home.file.".config/niri/config.kdl".source = ../../static/niri.kdl;

    services.wob = {
      enable = true;
      settings = with config.colorScheme.palette; {
        "" = {
          timeout = 750;
          background_color = "${base00}88";
          bar_color = base05;
          border_color = base05;
        };
      };
    };

    services.fnott = {
      enable = true;
      extraFlags = [ "-s" ];
      settings = (
        with config.colorScheme.palette;
        {
          main = {
            background = "${base00}cc";
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
          terminal = "${lib.getExe config.bpletza.workstation.terminal.default} -e";
          dpi-aware = false;
          font = "Recursive Sans Casual Static:size=11";
          icon-theme = config.gtk.iconTheme.name;
          show-actions = true;
          use-bold = true;
        };
        colors = {
          # https://github.com/folke/tokyonight.nvim/blob/main/extras/fuzzel/tokyonight_night.ini
          background = "16161ecc";
          text = "c0caf5ff";
          match = "2ac3deff";
          selection = "343a55ff";
          selection-match = "2ac3deff";
          selection-text = "c0caf5ff";
          border = "27a1b9ff";
        };
      };
    };

    systemd.user.services.shikane = {
      Unit = {
        X-Restart-Triggers = config.xdg.configFile."shikane/config.toml".source;
      };
    };

    services.shikane = {
      enable = true;
      settings =
        let
          internalDisplay = [ "n=${oscfg.internalDisplay}" ];
          allOutputs = [ "n/HDMI-[A-Z]-[1-9]+" ];
          homeLeft = [
            "v=Dell Inc."
            "m=DELL U2520D"
            "s=8KQLGZ2"
          ];
          homeRight = [
            "v=Dell Inc."
            "m=DELL U2520D"
            "s=79PLGZ2"
          ];
          muccc1 = [
            "v=AOC"
            "m=U2790B"
            "s=0x0000579E"
          ];
          muccc2 = [
            "v=Dell Inc."
            "m=DELL U2713HM"
            "s=GK0KD2AC662L"
          ];
        in
        {
          profile = [
            {
              name = "home-docked";
              output = [
                {
                  search = internalDisplay;
                  enable = false;
                }
                {
                  search = homeLeft;
                  enable = true;
                  position.x = 0;
                  position.y = 0;
                }
                {
                  search = homeRight;
                  enable = true;
                  position.x = 2560;
                  position.y = 0;
                }
              ];
            }
            {
              name = "home";
              output = [
                {
                  search = homeLeft;
                  enable = true;
                  position.x = 0;
                  position.y = 0;
                }
                {
                  search = homeRight;
                  enable = true;
                  position.x = 2560;
                  position.y = 0;
                }
              ];
            }
            {
              name = "builtin-and-external-default";
              output = [
                {
                  search = allOutputs;
                  enable = true;
                  mode.width = 1920;
                  mode.height = 1080;
                  position.x = 0;
                  position.y = 0;
                }
                {
                  search = internalDisplay;
                  enable = true;
                  scale = lib.mkIf (!isNull oscfg.displayScale) oscfg.displayScale;
                  position.x = 1920;
                  position.y = 0;
                }
              ];
            }
            {
              name = "builtin-only";
              output = [
                {
                  search = internalDisplay;
                  enable = true;
                  scale = lib.mkIf (!isNull oscfg.displayScale) oscfg.displayScale;
                  position.x = 0;
                  position.y = 0;
                }
              ];
            }
            {
              name = "muccc-hauptraum1";
              output = [
                {
                  search = muccc1;
                  enable = true;
                  position.x = 0;
                  position.y = 0;
                  mode.width = 3840;
                  mode.height = 2160;
                  scale = 1.5;
                }
                {
                  search = internalDisplay;
                  enable = true;
                  position.x = 0;
                  position.y = 1440;
                  scale = lib.mkIf (!isNull oscfg.displayScale) oscfg.displayScale;
                }
              ];
            }
            {
              name = "muccc-hauptraum2";
              output = [
                {
                  search = muccc2;
                  enable = true;
                  position.x = 0;
                  position.y = 0;
                  mode.width = 2560;
                  mode.height = 1440;
                }
                {
                  search = internalDisplay;
                  enable = true;
                  position.x = 0;
                  position.y = 1440;
                  scale = lib.mkIf (!isNull oscfg.displayScale) oscfg.displayScale;
                }
              ];
            }
          ];
        };
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
