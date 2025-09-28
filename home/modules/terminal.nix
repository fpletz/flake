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
      default = pkgs.alacritty;
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
              regex = "(ipfs:|ipns:|magnet:|mailto:|gemini:|gopher:|https:|http:|news:|file:|git:|ssh:|ftp:)[^\\u0000-\\u001F\\u007F-\\u009F<>\"\\\\s{-}\\\\^⟨⟩`]+";
              command = "xdg-open";
              post_processing = true;
              mouse = {
                enabled = true;
                mods = "None";
              };
              binding = {
                key = "U";
                mods = "Control|Shift";
              };
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
      settings = {
        background = "black";
        window-padding-color = "background";
        font-family = "0xProto";
        font-size = 10;
        mouse-hide-while-typing = true;
        auto-update = "off";
        gtk-titlebar = false;
        shell-integration = "none";
        linux-cgroup = "always";
        resize-overlay = "never";
      };
    };
  };
}
