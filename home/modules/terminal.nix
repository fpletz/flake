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
      default = config.bpletza.workstation.sway;
    };

    default = lib.mkOption {
      type = lib.types.str;
      default = lib.getExe pkgs.alacritty;
    };
  };

  config = lib.mkIf config.bpletza.workstation.terminal.enable {
    programs.alacritty = {
      enable = true;
      settings = {
        font = {
          normal.family = "Fira Code";
          size = 10.0;
        };
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
          import = [ "${pkgs.vimPlugins.tokyonight-nvim}/extras/alacritty/tokyonight_night.toml" ];
          live_config_reload = true;
        };
      };
    };

    programs.kitty = {
      enable = true;
      font = {
        name = "Fira Code";
        size = 10;
      };
      settings = {
        scrollback_lines = 4000;
        enable_audio_bell = false;
        update_check_interval = 0;
        tab_bar_min_tabs = 2;
        tab_bar_edge = "bottom";
        tab_bar_style = "powerline";
        tab_powerline_style = "slanted";
        tab_title_template = "{title}{' :{}:'.format(num_windows) if num_windows > 1 else ''}";
        wayland_enable_ime = false;
      };
      shellIntegration = {
        enableBashIntegration = true;
        enableZshIntegration = true;
      };
      extraConfig = ''
        include ${pkgs.vimPlugins.tokyonight-nvim}/extras/kitty/tokyonight_night.conf
      '';
    };
  };
}
