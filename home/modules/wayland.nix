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
      pkgs.bzmenu
      pkgs.shikane
      pkgs.swww
    ];

    home.file.".config/niri/config.kdl".source = ../../static/niri.kdl;

    services.wob = {
      enable = true;
      settings = {
        "" = {
          timeout = 750;
        };
      };
    };

    services.fnott = {
      enable = true;
      extraFlags = [ "-s" ];
      settings = {
        main = {
          icon-theme = config.gtk.iconTheme.name;
          max-icon-size = 64;
          # default-timeout = 10;
          # max-timeout = 30;
          min-width = 300;
          max-width = 1000;
          selection-helper = "${lib.getExe pkgs.fuzzel} -d";
          summary-format = "<b>%s</b>";
          padding-vertical = 15;
          padding-horizontal = 15;
        };
      };
    };

    programs.fuzzel = {
      enable = true;
      settings = {
        main = {
          launch-prefix = "systemd-run --user --scope --slice=app";
          terminal = "${lib.getExe config.bpletza.workstation.terminal.default} -e";
          dpi-aware = false;
          icon-theme = config.gtk.iconTheme.name;
          show-actions = true;
          use-bold = true;
        };
      };
    };

    systemd.user.services.shikane = {
      Unit = {
        X-Restart-Triggers = [ config.xdg.configFile."shikane/config.toml".source ];
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
          ]
          ++ lib.optionals (oscfg.internalDisplay != null) [
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

    programs.wleave = {
      enable = true;
      settings = {
        margin = 200;
        buttons-per-row = "1/2";
        delay-command-ms = 100;
        close-on-lost-focus = true;
        show-keybinds = true;
        no-version-info = true;
        buttons = [
          {
            label = "lock";
            action = "loginctl lock-session";
            text = "Lock";
            keybind = "l";
            icon = "${pkgs.wleave}/share/wleave/icons/lock.svg";
          }
          {
            label = "logout";
            action = "loginctl terminate-user $USER";
            text = "Logout";
            keybind = "e";
            icon = "${pkgs.wleave}/share/wleave/icons/logout.svg";
          }
          {
            label = "suspend";
            action = "systemctl suspend";
            text = "Suspend";
            keybind = "u";
            icon = "${pkgs.wleave}/share/wleave/icons/suspend.svg";
          }

          {
            label = "shutdown";
            action = "systemctl poweroff";
            text = "Shutdown";
            keybind = "s";
            icon = "${pkgs.wleave}/share/wleave/icons/shutdown.svg";
          }
        ];
      };
    };
  };
}
