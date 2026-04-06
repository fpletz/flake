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
    ];

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
              name = "home-docked";
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
                {
                  search = internalDisplay;
                  enable = false;
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
  };
}
