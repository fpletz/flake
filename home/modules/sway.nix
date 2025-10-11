{
  osConfig,
  config,
  lib,
  pkgs,
  ...
}:
{
  options.bpletza.workstation.sway = lib.mkOption {
    type = lib.types.bool;
    default = osConfig.programs.sway.enable;
  };

  config = lib.mkIf config.bpletza.workstation.sway {
    wayland.windowManager.sway = {
      enable = true;
      extraSessionCommands = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        export QT_QPA_PLATFORM=wayland
        export XDG_SESSION_TYPE="wayland"
        export XDG_CURRENT_DESKTOP="sway"
        export EGL_PLATFORM=wayland
        export NIXOS_OZONE_WL=1
      '';
      systemd = {
        enable = true;
        dbusImplementation = "broker";
        extraCommands = [ ];
      };
      config = {
        input = {
          "type:touchpad" = {
            accel_profile = "adaptive";
            pointer_accel = "0.5";
            dwt = "enabled";
            dwtp = "enabled";
            tap = "enabled";
            natural_scroll = "enabled";
          };
          "type:keyboard" = {
            xkb_layout = "eu";
            xkb_options = "compose:caps";
            repeat_delay = "400";
            repeat_rate = "40";
          };
          "2:10:TPPS/2_IBM_TrackPoint" = {
            middle_emulation = "enabled";
            accel_profile = "flat";
            pointer_accel = "0.8";
          };
        };
        modifier = "Mod4";
        terminal = "systemd-run --user --scope --slice=app ${lib.getExe config.bpletza.workstation.terminal.default}";
        defaultWorkspace = "workspace number 1";
        window = {
          titlebar = false;
          hideEdgeBorders = "smart";
          border = 1;
        };
        floating = {
          titlebar = false;
          criteria = [
            { "title" = "LibreWolf - Sharing Indicator"; }
            { "title" = "LibreWolf - Choose User Profile"; }
            { "title" = "Firefox - Sharing Indicator"; }
            { "title" = "Firefox - Choose User Profile"; }
            {
              "app_id" = "librewolf";
              "title" = "Extension:.*";
            }
            { "class" = "qemu"; }
            { "app_id" = "xdg-desktop-portal-gtk"; }
            { "app_id" = "org.keepassxc.KeePassXC"; }
          ];
        };
        bars = [ ];
        keybindings = lib.mkOptionDefault {
          "Mod4+Shift+e" = "exec wleave";
          "Mod4+d" = "exec fuzzel";
          "Mod4+Shift+d" = "exec ${lib.getExe pkgs.emoji-picker}";
          "Mod4+p" = "exec ${lib.getExe pkgs.tessen}";
          "Mod4+Shift+a" = "exec ${pkgs.fnott}/bin/fnottctl actions";
          "Mod4+Shift+s" = "exec ${pkgs.fnott}/bin/fnottctl dismiss";
          "Mod4+Ctrl+s" = "exec ${lib.getExe pkgs.grim} -g \"$(${lib.getExe pkgs.slurp} -d)\" - | wl-copy";
          "Mod4+Ctrl+l" = "exec loginctl lock-session";
          "Mod4+Ctrl+Left" = "move workspace to output left";
          "Mod4+Ctrl+Right" = "move workspace to output right";
          "Mod4+Ctrl+Up" = "move workspace to output up";
          "Mod4+Ctrl+Down" = "move workspace to output down";
          "XF86MonBrightnessDown" = "exec swayosd-client --brightness lower";
          "XF86MonBrightnessUp" = "exec swayosd-client --brightness raise";
          "XF86AudioMute" = "exec swayosd-client --output-volume mute-toggle";
          "XF86AudioLowerVolume" = "exec swayosd-client --output-volume lower";
          "XF86AudioRaiseVolume" = "exec swayosd-client --output-volume raise";
          "Mod4+XF86AudioMute" = "exec swayosd-client --input-volume mute-toggle";
          "XF86AudioMicMute" = "exec swayosd-client --input-volume mute-toggle";
          "Mod4+XF86AudioLowerVolume" = "exec swayosd-client --input-volume lower";
          "Mod4+XF86AudioRaiseVolume" = "exec swayosd-client --input-volume raise";
          "--whole-window --border --no-repeat BTN_SIDE" = "exec mumble rpc starttalking";
          "--whole-window --border --no-repeat --release BTN_SIDE" = "exec mumble rpc stoptalking";
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
          {
            command = "shikanectl reload";
            always = true;
          }
        ];
        workspaceAutoBackAndForth = true;
      };
      wrapperFeatures.gtk = true;
    };

    services.swayosd = {
      enable = true;
    };

    systemd.user.services.swayosd = {
      Unit.PartOf = [
        "wayland-session@sway.target"
        "sway-session.target"
      ];
    };

    services.wpaperd = {
      enable = true;
      settings = {
        default = {
          duration = "5m";
        };
        any.path = ../../static/wallpapers;
      };
    };
  };
}
