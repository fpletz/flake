{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.bpletza.workstation.terminal = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = config.bpletza.workstation.wayland;
    };

    default = lib.mkOption {
      type = lib.types.package;
      default = pkgs.ghostty;
    };
  };

  config = lib.mkIf config.bpletza.workstation.terminal.enable {
    home.sessionVariables = {
      TERMINAL = config.bpletza.workstation.terminal.default.meta.mainProgram;
    };

    programs.alacritty = {
      enable = true;
      settings = {
        scrolling = {
          history = 20000;
        };
        hints = {
          enabled = [
            {
              command = "xdg-open";
              hyperlinks = true;
              post_processing = true;
            }
          ];
        };
        general = {
          live_config_reload = true;
        };
      };
    };

    programs.ghostty = {
      enable = true;
      systemd.enable = true;
      settings = {
        background = "black";
        background-opacity = 0.85;
        background-blur = false;
        window-padding-color = "background";
        auto-update = "off";
        gtk-titlebar = false;
        shell-integration = "none";
        shell-integration-features = "cursor,sudo,title";
        linux-cgroup = "always";
        resize-overlay = "never";
      };
    };
  };
}
